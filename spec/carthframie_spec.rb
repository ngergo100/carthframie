RSpec.describe Carthframie do
  it "has a version number" do
    expect(Carthframie::VERSION).not_to be nil
  end
  
  it "has frameworks path" do
    expect(Carthframie::CarthageCopyFrameworks::CARTHAGE_FRAMEWORKS_PATH).to eq("Carthage/Build/**/*.framework")
  end
  
  it "has build phase name" do
    expect(Carthframie::CarthageCopyFrameworks::COPY_CARTHAGE_BUILD_PHASE_NAME).to eq("Copy Carthage frameworks")
  end
  
  it "has shell script" do
    expect(Carthframie::CarthageCopyFrameworks::COPY_CARTHAGE_BUILD_PHASE_SHELL_SCRIPT).to eq("/usr/local/bin/carthage copy-frameworks")
  end
  
  it "has source root" do
    expect(Carthframie::CarthageCopyFrameworks::SRCROOT).to eq("$(SRCROOT)")
  end
  
  it "has .app build path" do
    expect(Carthframie::CarthageCopyFrameworks::BUILT_PRODUCTS_DIR_FRAMEWORKS_FOLDER_PATH).to eq("$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)")
  end
end
