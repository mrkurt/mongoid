require 'spec_helper'

describe Mongoid::Locking do
  context "#existing" do
    context "#persist" do
      let(:post) do
        LockablePost.new(:_id => BSON::ObjectID.new.to_s, :title => "Sometime awesome", :lock_version => '1234')
      end

      let(:collection) do
        stub.quacks_like(Mongoid::Collection.allocate)
      end

      before do
        post.stubs(:collection).returns(collection)
      end

      def root_set_expectation
        lambda {
          collection.expects(:update).with do |selector, setters, options|
            selector == post._selector && setters['$set']['title'] == 'Something more awesome'
          end
        }
      end

      let(:update) do
        Mongoid::Persistence::Update.new(post)
      end

      context "when the document is changed" do
        before do
          post.title = "Something more awesome"
        end

        it "performs a $set with the proper selector" do
          root_set_expectation.call
          update.persist.should == true 
        end

        context "and before_save is done" do
          before do
            post.send(:update_lock_version) #normally done in a before_save
          end

          it "the selector includes the original lock_version field" do
            post._selector['lock_version'].should == '1234'
          end

          it "the setters include a new lock_version field" do
            post.setters.should have_key('lock_version')
          end
        end

      end
    end
  end
end
