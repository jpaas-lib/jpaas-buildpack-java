require "fileutils"
require "jpaas_pack/java"

module JpaasPack
  class JavaStandalone < Java

    def self.use?
      Dir.glob("**/*.jar").any? || Dir.glob("**/*.class").any?
    end

    def name
      "Java Standalone"
    end

    def do_compile
        install_java
        setup_profiled
    end

    def java_opts
      super.merge({ "-Dhttp.port=" => "$PORT" })
    end

  end
end
