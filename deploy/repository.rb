class Repository
  def repo
    @repo ||= Rugged::Repository.discover('.')
  end

  def tag_exists?(tag)
    repo.tags.map(&:name).include? tag
  end

  def sync!
    return if tag_exists?
    commit
    tag
    push
  end

  def index_modified?
    changeset = {}
    repo.status do |file,status|
      changeset[status.join] ||= []
      changeset[status.join]<<file
    end
    changeset.keys.include? 'index_modified'
  end

  private
  def commit!
    puts "Writing version.txt..."
    require 'fileutils'
    FileUtils.mkdir_p 'public'
    File.open('public/version.txt', 'w') do |file|
      file.write(@tag)
    end
    puts "Tagging #{@tag} as new version and committing."
    message = "#{last_commit_message} - deploy"
    index.add path: 'public/version.txt',
              oid: (Rugged::Blob.from_workdir repo, 'public/version.txt'),
              mode: 0100644
    commit_tree = index.write_tree repo
    index.write
    Rugged::Commit.create repo,
      author: author,
      committer: author,
      message: message,
      parents: [head.target],
      tree: commit_tree,
      update_ref: 'HEAD'
  end

  def tag_collection
    @tag_collection ||= Rugged::TagCollection.new(repo)
  end

  def tag!
    tag_collection.create(@tag, head.target.oid)
  end

  def push!
    # Have to invoke git binary here, as gem won't push.
    unless system('git push origin HEAD') && system('git push origin --tags')
      fail "Failed to git push."
    end
  end

  # Helper Git methods
  def index
    repo.index
  end

  def head
    repo.head
  end

  def now
    @now ||= Time.now
  end

  def last_commit_message
    @last_commit_message ||= head.target.message
  end

  def author
    @author ||= {
      name:  repo.config.get('user.name'),
      email: repo.config.get('user.email'),
      time:  now
    }
  end
end
