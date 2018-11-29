require 'yaml'

class BuildMatrix
  def initialize
    @conf = configuration

    # build_upstreams(@conf[:builds])
    # checkout_repos(@conf[:builds])
    # clone_base_repo(@conf[:builds].first)
    # fetch_origin(@conf[:builds].first)
    # checkout_pr(@conf[:builds].first)
  end


  def clone_base_repo(repo)
    `git clone #{repo[:upstream]} --single-branch build`
  end

  def fetch_origin(repo)
    Dir.chdir("build")
    `git fetch origin pull/#{repo[:id]}/head:pr/#{repo[:id]}`
  end

  def checkout_pr(repo)
    Dir.chdir("build") unless File.basename(Dir.getwd).eql?("build")
    `git checkout pr/#{repo[:id]}`
  end

  # git fetch origin pull/123/head:pr/123 && git checkout pr/123

  # def build_upstreams(upstreams)
  #   upstreams.each do |upstream|
  #     `git remote add #{upstream[:name]} #{upstream[:upstream]}`
  #   end
  # end
  #
  # def checkout_repos(repos)
  #   repos.each do |repo|
  #     # `git -C build fetch #{repo[:name]} pull/#{repo[:id]}/head:#{repo[:branch]}`
  #     # `git fetch #{repo[:name]} +refs/pull/#{repo[:id]}/merge`
  #     # `git fetch #{repo[:name]} +refs/pull/*/merge:refs/remotes/origin/pr/*`
  #     # `cd build ; git checkout -b #{repo[:name]} #{repo[:name]}/#{repo[:branch]}`
  #     # `cd build; git checkout #{repo[:name]}/pr/#repo[:id]}`
  #     # `cd build ; git checkout origin/pr/#{repo[:id]}`
  #   end
  # end

  def configuration(file = "build_matrix.yml")
    config_file = YAML.load_file(file)
    config = {}
    return unless config_file
    symbolise(config_file)
  end

  # code from https://gist.github.com/Integralist/9503099
  def symbolise(obj)
    if obj.is_a? Hash
      return obj.inject({}) do |hash, (k, v)|
        hash.tap { |h| h[k.to_sym] = symbolise(v) }
      end
    elsif obj.is_a? Array
      return obj.map { |hash| symbolise(hash) }
    end
    obj
  end
end


build = BuildMatrix.new
