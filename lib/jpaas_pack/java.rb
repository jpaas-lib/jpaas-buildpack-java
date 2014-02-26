require "fileutils"
require "yaml"
require "jpaas_pack/packager"

module JpaasPack
  class Java
   
    attr_reader :build_path, :cache_path

    include JpaasPack::Packager
    # @param [String] the path of the build dir
    # @param [String] the path of the cache dir
    def initialize(build_path, cache_path=nil)
      @build_path = build_path
      @cache_path = cache_path
    end

    # changes directory to the build_path
    def compile
      Dir.chdir(build_path) do
        do_compile
      end
    end

    def do_compile
      raise NotImplementedError, "subclasses must implement a 'do_compile' method"
    end

    def install_java
      FileUtils.mkdir_p jdk_dir
      download_jdk(jdk_tarball)

      puts "INFO: unpacking JDK to #{jdk_dir} ..."
      tar_output = run_with_err_output "tar pxzf #{jdk_tarball} -C #{jdk_dir}"

      FileUtils.rm_rf jdk_tarball
      unless File.exists?("#{jdk_dir}/bin/java")
        puts "FATAL: unable to retrieve the JDK"
        puts tar_output
        exit 1
      end
      puts "INFO: unpacking JDK to #{jdk_dir} is done"
    end

    def jdk_dir
      ".jdk"
    end

    def java_opts
      {
        "-Xmx" => "$MEMORY_LIMIT",
        "-Xms" => "$MEMORY_LIMIT",
        "-Djava.io.tmpdir=" => '\"$TMPDIR\"'
      }
    end

    def jdk_tarball
      "#{jdk_dir}/jdk.tar.gz"
    end

    def release
      {
          "addons" => [],
          "config_vars" => {},
          "default_process_types" => default_process_types
      }.to_yaml
    end

    def default_process_types
      raise NotImplementedError, "subclasses must implement a 'default_process_types' method"
    end

    # run a shell comannd and pipe stderr to stdout
    def run_with_err_output(command)
      %x{ #{command} 2>&1 }
    end

    def setup_profiled
      FileUtils.mkdir_p "#{build_path}/.profile.d"
      File.open("#{build_path}/.profile.d/java.sh", "a") { |file| file.puts(bash_script) }
    end

    private

    def bash_script
      <<-BASH
#!/bin/bash
export JAVA_HOME="$HOME/#{jdk_dir}"
export PATH="$HOME/#{jdk_dir}/bin:$PATH"
export JAVA_OPTS=${JAVA_OPTS:-"#{java_opts.map{ |k, v| "#{k}#{v}" }.join(' ')}"}
if [ -n "$VCAP_DEBUG_MODE" ]; then
  if [ "$VCAP_DEBUG_MODE" = "run" ]; then
    export JAVA_OPTS="$JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,address=$VCAP_DEBUG_PORT,server=y,suspend=n"
  elif [ "$VCAP_DEBUG_MODE" = "suspend" ]; then
    export JAVA_OPTS="$JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,address=$VCAP_DEBUG_PORT,server=y,suspend=y"
  fi
fi
      BASH
    end

  end
end
