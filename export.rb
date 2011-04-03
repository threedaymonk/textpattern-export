require "active_record"
require "yaml"
require "open3"
require "time"

class Post < ActiveRecord::Base
  set_table_name "textpattern"
  set_primary_key "ID"

  STATUS = %w[ _ draft hidden pending live sticky ]

  def metadata
    {
       :id         => self.id,
       :posted_at  => self.Posted,
       :updated_at => self.LastMod,
       :title      => self.Title,
       :section    => self.Section,
       :slug       => self.url_title,
       :status     => STATUS[self.Status]
    }
  end

  def body
    self.Body_html
  end
end

class Comment < ActiveRecord::Base
  set_table_name "txp_discuss"
  set_primary_key "discussid"

  def metadata
    {
      :id         => self.id,
      :post_id    => self.parentid,
      :name       => self.name,
      :email      => self.email,
      :url        => self.web,
      :ip_address => self.ip,
      :posted_at  => self.posted,
      :visible    => self.visible,
      :user_agent => self.useragent
    }
  end

  def body
    ("<p>" + self.message.strip + "</p>").
      gsub(%r!(?:<br\s?/?>\s*){2}!, "</p><p>").
      gsub(%r!<p>\s*<p>!, "<p>").
      gsub(%r!</p>\s*</p>!, "</p>")
  end
end

def tidy(html)
  stdin, stdout, stderr = Open3.popen3("tidy -q -asxml -utf8")
  stdin << html
  stdin.close
  stdout.read[%r!<body>(.*?)</body>!m, 1].strip.
    gsub(%r!(<pre[^>]*>)\s+!, "\\1").
    gsub(%r!\s+(</pre>)!, "\\1")
end

def headers(hash)
  hash.map{ |k, v|
    [k, Time === v ? v.utc.xmlschema : v].join(": ")
  }.join("\n")
end

config = YAML.load(File.read("config.yaml"))
ActiveRecord::Base.establish_connection config[:database]

FileUtils.mkdir_p "export/comments"
Dir.chdir "export/comments" do
  Comment.all.each do |comment|
    filename = "%06d-%06d" % [comment.metadata[:post_id], comment.metadata[:id]]
    File.open filename, "w" do |f|
      f.puts headers(comment.metadata), "", tidy(comment.body)
    end
  end
end

FileUtils.mkdir_p "export/posts"
Dir.chdir "export/posts" do
  Post.all.each do |post|
    filename = "%06d-%s" % [post.metadata[:id], post.metadata[:slug]]
    File.open filename, "w" do |f|
      f.puts headers(post.metadata), "", tidy(post.body)
    end
  end
end
