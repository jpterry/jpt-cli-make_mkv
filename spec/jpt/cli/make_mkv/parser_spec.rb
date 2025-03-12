# frozen_string_literal: true

RSpec.describe JPT::CLI::MakeMkv::Parser do
  describe "text fixtures" do
    describe "fixture of makemkvcon:" do
      # eg makemkvcon_info_disc_0_willy_wonka_hd.log
      describe "makemkvcon --robot --messages=-stdout --progress=-same --decrypt info disc:0" do
        let(:parser) { JPT::CLI::MakeMkv::Parser.parse_file!("spec/fixtures/makemkvcon_info_disc_0_willy_wonka_hd.log", command: :info) }
        it "returns a correct disk info" do
          disc_info = parser.result[:disc_info]
          expect(disc_info).to_not be_nil

          expect(disc_info.tcount).to eq(16)
          expect(disc_info.attributes).to include(
            "Name" => "Willy Wonka and the Chocolate Factory",
            "Type" => "Blu-ray disc",
            "Volume name" => "WILLY_WONKA"
          )
        end
      end

      describe "makemkvcon --robot --noscan --messages=-stdout --progress=-same --decrypt backup disc:0 $BACKUPS_PATH/WILLY_WONKA" do
        let(:parser) { JPT::CLI::MakeMkv::Parser.parse_file!("spec/fixtures/makemkvcon_backup_disc_0_willy_wonka_hd.log", command: :backup) }
      end

      describe "makemkvcon --noscan --robot --messages=-stdout --progress=-same --decrypt mkv $BACKUPS_PATH/WILLY_WONKA 2 /Volumes/BEBOP/MovieBackups/Testing"
    end
  end
  describe ".parse_file!"
end
