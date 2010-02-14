# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'radio input' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
  end

  describe 'for belongs_to association' do
    before do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:author, :as => :radio, :value_as_class => true))
      end
    end
    
    it_should_have_input_wrapper_with_class("radio")
    it_should_have_input_wrapper_with_id("post_author_input")
    it_should_have_a_nested_fieldset
    it_should_apply_error_logic_for_input_type(:radio)
    it_should_use_the_collection_when_provided(:radio, 'input')
    
    
    it 'should generate a legend - classified as a label - containing label text for the input' do
      output_buffer.should have_tag('form li fieldset legend.label')
      output_buffer.should have_tag('form li fieldset legend.label', /Author/)
    end

    it 'should generate an ordered list with a list item for each choice' do
      output_buffer.should have_tag('form li fieldset ol')
      output_buffer.should have_tag('form li fieldset ol li', :count => ::Author.find(:all).size)
    end

    describe "each choice" do

      it 'should contain a label for the radio input with a nested input and label text' do
        ::Author.find(:all).each do |author|
          output_buffer.should have_tag('form li fieldset ol li label', /#{author.to_label}/)
          output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_id_#{author.id}']")
        end
      end

      it 'should use values as li.class when value_as_class is true' do
        ::Author.find(:all).each do |author|
          output_buffer.should have_tag("form li fieldset ol li.author_#{author.id} label")
        end
      end

      it "should have a radio input" do
        ::Author.find(:all).each do |author|
          output_buffer.should have_tag("form li fieldset ol li label input#post_author_id_#{author.id}")
          output_buffer.should have_tag("form li fieldset ol li label input[@type='radio']")
          output_buffer.should have_tag("form li fieldset ol li label input[@value='#{author.id}']")
          output_buffer.should have_tag("form li fieldset ol li label input[@name='post[author_id]']")
        end
      end

      it "should mark input as checked if it's the the existing choice" do
        output_buffer.replace ''
        @new_post.author_id.should == @bob.id
        @new_post.author.id.should == @bob.id
        @new_post.author.should == @bob

        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:author, :as => :radio))
        end

        output_buffer.should have_tag("form li fieldset ol li label input[@checked='checked']")
      end
    end

    describe 'and no object is given' do
      before(:each) do
        output_buffer.replace ''
        semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.input(:author_id, :as => :radio, :collection => ::Author.find(:all)))
        end
      end

      it 'should generate a fieldset with legend' do
        output_buffer.should have_tag('form li fieldset legend', /Author/)
      end

      it 'should generate an li tag for each item in the collection' do
        output_buffer.should have_tag('form li fieldset ol li', :count => ::Author.find(:all).size)
      end

      it 'should generate labels for each item' do
        ::Author.find(:all).each do |author|
          output_buffer.should have_tag('form li fieldset ol li label', /#{author.to_label}/)
          output_buffer.should have_tag("form li fieldset ol li label[@for='project_author_id_#{author.id}']")
        end
      end

      it 'should generate inputs for each item' do
        ::Author.find(:all).each do |author|
          output_buffer.should have_tag("form li fieldset ol li label input#project_author_id_#{author.id}")
          output_buffer.should have_tag("form li fieldset ol li label input[@type='radio']")
          output_buffer.should have_tag("form li fieldset ol li label input[@value='#{author.id}']")
          output_buffer.should have_tag("form li fieldset ol li label input[@name='project[author_id]']")
        end
      end
    end
  end

  describe ':default option' do
    
    describe "when the object has a value" do
      it "should select the object value (ignoring :default)" do
        output_buffer.replace ''
        @new_post.stub!(:author_id => @bob.id, :author => @bob)
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:author, :as => :radio, :default => @fred.id))
        end
        output_buffer.should have_tag("form li input[@checked]", :count => 1)
        output_buffer.should have_tag("form li input#post_author_id_#{@bob.id}[@checked]", :count => 1)
      end
    end
    
    describe 'when the object has no value' do
      before do
        @new_post.stub!(:author_id => nil, :author => nil)
      end
      
      it "should select the :default if provided" do
        output_buffer.replace ''
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:author, :as => :radio, :default => @fred.id))
        end
        output_buffer.should have_tag("form li input[@checked]", :count => 1)
        output_buffer.should have_tag("form li input#post_author_id_#{@fred.id}[@checked]", :count => 1)
      end
      
      it "should not select an option if the :default is provided as nil" do
        output_buffer.replace ''
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:author_id, :as => :radio, :default => nil))
        end
        output_buffer.should_not have_tag("form li ol li input#post_created_at_1i option[@checked]")
      end
    end
    
    it 'should strip the :default and :selected options from the HTML' do
      output_buffer.replace ''
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:author_id, :as => :radio, :default => nil))
      end
      output_buffer.should_not =~ /selected/
      output_buffer.should_not =~ /default/
    end
    
  end
  
  it 'should warn about :selected deprecation' do
    with_deprecation_silenced do
      ::ActiveSupport::Deprecation.should_receive(:warn)
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:author_id, :as => :radio, :selected => @bob.id))
      end
    end
  end
  
  it 'should warn about :checked deprecation' do
    with_deprecation_silenced do
      ::ActiveSupport::Deprecation.should_receive(:warn)
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:author_id, :as => :radio, :checked => @bob.id))
      end
    end
  end
  
  
end
