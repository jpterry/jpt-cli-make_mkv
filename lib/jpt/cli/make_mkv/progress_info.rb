# frozen_string_literal: true

require_relative "string_helpers"

module JPT
  module CLI
    module MakeMkv
      class ProgressInfo
        include StringHelpers

        def initialize
          @prgt = nil
          @prgc = nil
          @prgv = nil
        end

        def set_prgc_info(body)
          _, _, name = body_parse_as_csv(body)

          reset_current_log
          Console.info(self, "Set PRGC: #{name}")
          @prgc = name
        end

        def set_prgt_info(body)
          _, _, name = body_parse_as_csv(body)

          reset_total_log
          Console.info(self, "Set PRGT: #{name}")
          @prgt = name
        end

        def calc_progress(curr, max)
          return 0 if curr.to_i <= 0
          (curr.to_f / max.to_f * 100).round
        end

        def reset_current_log
          @current_log_points = (1..100).to_a
        end

        def reset_total_log
          @total_log_points = (1..100).to_a
        end

        def set_prgv_info(body)
          # This is so we only notify once per progress point.

          @prgv = body.strip
          current, total, max = split3(@prgv)

          @current_progress = calc_progress(current, max)
          @total_progress = calc_progress(total, max)

          @current_log_points ||= reset_current_log
          @total_log_points ||= reset_total_log

          if @current_log_points.any? && @current_progress > @current_log_points.first
            @current_log_points.delete_if { |x| x <= @current_progress }
            # Notify about progress change
            Console.info(self, "#{@prgc}: #{@current_progress}% Completed")
          end

          if @total_log_points.any? && @total_progress > @total_log_points.first
            @total_log_points.delete_if { |x| x <= @total_progress }
            # Notify about progress change
            Console.info(self, "#{@prgt}: #{@total_progress}% Completed")
          end
        end

        def split3(line)
          line.strip.split(",", 3)
        end

        def parse_progress_line(line)
          type, body = line.split(":", 2)
          case type
          when "PRGC"
            set_prgc_info(body)
          when "PRGT"
            set_prgt_info(body)
          when "PRGV"
            set_prgv_info(body)
          else
            Console.warn "ProgressInfo received unhandled line: #{line}"
          end
        end
      end
    end
  end
end
