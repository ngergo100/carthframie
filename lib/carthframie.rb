require "carthframie/version"
require "xcodeproj"
require "thor"

module Carthframie

  class CarthageCopyFrameworks

    CARTHAGE_FRAMEWORKS_PATH = "Carthage/Build/**/*.framework"
    COPY_CARTHAGE_BUILD_PHASE_NAME = "Copy Carthage frameworks"
    COPY_CARTHAGE_BUILD_PHASE_SHELL_SCRIPT = "/usr/local/bin/carthage copy-frameworks"
    SRCROOT = "$(SRCROOT)"
    BUILT_PRODUCTS_DIR_FRAMEWORKS_FOLDER_PATH = "$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)"

    def initialize(project_path, choosen_target_name)
      puts("ℹ️  Loading #{project_path}...")
      @root = File.dirname(project_path)
      @project = Xcodeproj::Project.open(project_path)
      puts("🎉 #{project_path} has been successfully loaded.")

      puts("ℹ️  Looking for #{choosen_target_name} target in your project...")
      targets = @project.targets.select { |target| target.name == choosen_target_name }
      if targets.count > 1 then
        puts("⚠️  Multiple targets found with name '#{choosen_target_name}'. Loaded the first one. Please check your target configuration.")
      elsif targets.count == 1 then
        puts("🎉 #{choosen_target_name} has been successfully loaded.")
      else 
        puts("❌  Did not find target with the given name. Exiting now...")
        exit
      end
      @target = targets.first
    end
    
    ## Run function

    def run 
      get_frameworks_built_by_carthage
      
      remove_carthage_copy_frameworks_build_phase_if_needed
      
      add_frameworks_to_frameworks_group_if_needed
      
      add_new_copy_frameworks_build_phase
      
      puts("ℹ️  Saving project...")
      @project.save
      puts("🎉 Project saved.")
    end
    
    ## Helper functions
    
    def get_frameworks_built_by_carthage
      puts("ℹ️  Looking for frameworks in your project...")
      @framework_paths = Dir[CARTHAGE_FRAMEWORKS_PATH] # Finds '.framework' files recursively
      if @framework_paths.count > 0 then
        @framework_names = @framework_paths.map { |file| File.basename(file) }
        puts("🎉 Found #{@framework_names.count} frameworks:\n  -  📦 #{@framework_names.join("\n  -  📦 ")}")
      else
        puts("❌️  Did not find any files with '.framework' extension. Exiting now...")
        exit
      end
    end
    
    def remove_carthage_copy_frameworks_build_phase_if_needed
      puts("ℹ️  Checking existing build phases...")
      carthage_build_phases = @target.shell_script_build_phases.select { |build_phase|
        build_phase.shell_script.include? " copy-frameworks" and build_phase.name.include? "Carthage" 
      }
      carthage_build_phases.each { |carthage_build_phase|
        puts("⚠️  Removing existing build phase with name '#{carthage_build_phase.name}'...")
        carthage_build_phase.remove_from_project
      }
    end
    
    def add_frameworks_to_frameworks_group_if_needed
      puts("ℹ️  Checking existing file references in the project...")
      project_file_paths = @project.files.map { |file| file.path }
      linked_frameworks_build_phase = @target.frameworks_build_phase.files_references.map { |file_reference| file_reference.path }
      @framework_paths.each { |framework_path|
        if !project_file_paths.include? framework_path then
          new_reference = @project.new_file(framework_path)
          new_reference.move(@project.frameworks_group)
          puts("🎉 New file created at path: #{new_reference.path}")
        else
          puts("ℹ️  Framework at path '#{framework_path}' is already added to the project")
        end
        
        if !linked_frameworks_build_phase.include? framework_path then
          existing_reference = @project.files.select { |file| file.path == framework_path }
          if existing_reference.count > 0 then # By now framework should be added to the file references
            @target.frameworks_build_phase.add_file_reference(existing_reference.first, true)
            puts("🎉 New framework has sucessfully linked to the target")
          else
            puts("❌️  Some error happened during adding existing framework to your linked binearies phase, check your framework configurations!")
          end

        else
          puts("ℹ️  Framework at path '#{framework_path}' is already linked to the target")
        end
      }
    end
    
    def add_new_copy_frameworks_build_phase
      puts("ℹ️  Creating '#{COPY_CARTHAGE_BUILD_PHASE_NAME}' build phase...")
      newBuildPhase = @target.new_shell_script_build_phase(COPY_CARTHAGE_BUILD_PHASE_NAME)
      newBuildPhase.shell_script = COPY_CARTHAGE_BUILD_PHASE_SHELL_SCRIPT
      newBuildPhase.input_paths = @framework_paths.map { |framework_path| "#{SRCROOT}/#{framework_path}" }
      newBuildPhase.output_paths = @framework_names.map { |framework_name| "#{BUILT_PRODUCTS_DIR_FRAMEWORKS_FOLDER_PATH}/#{framework_name}" }
      puts("🎉 Successfully added new copy build phase to #{@target.name} target.")
    end

  end
  
  class Cli < Thor

      desc 'add_frameworks Example.xcodeproj Example', 'Adds carthage framework to Example target of Example.xcodeproj'
      def add_frameworks(project, target)
        CarthageCopyFrameworks.new(project, target).run
      end
  end

end
