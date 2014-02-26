require "jpaas_pack/java_standalone"
require "jpaas_pack/java_web"
require "jpaas_pack/java_web_standalone"

module JpaasPack

  def self.detect(*args)
    Dir.chdir(args.first)

    pack = [ JavaWeb, JavaWebStandalone, JavaStandalone ].detect do |klass|
      klass.use?
    end

    pack ? pack.new(*args) : nil
  end

end


