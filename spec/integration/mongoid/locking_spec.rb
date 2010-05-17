require "spec_helper"

describe Mongoid::Locking do
  before do
    @post = LockablePost.new(:title => 'something')
  end

  context "when creating" do
    it "should set a lock version" do
      @post.save
      @post.lock_version.should_not be_nil
    end
  end

  context "when updating" do
    before do
      @post.save
    end
    
    it "should set a new lock version" do
      lv = @post.lock_version
      @post.save
      @post.lock_version.should_not == lv
    end

    context "a stale document" do
      before do 
        @post_stale = LockablePost.find(@post.id)
        @post.update_attributes(:title => "Something else")

        begin
          @post_stale.update_attributes(:title => "Something the same")
        rescue
          @error = $!
        end
        @post.reload
      end

      it "should not save the changes" do
        @post.title.should_not == @post_stale.title
      end

      it "should raise an exception" do
        @error.should be_a(Mongoid::Errors::NoDocumentsChanged)
      end
    end
  end
end
