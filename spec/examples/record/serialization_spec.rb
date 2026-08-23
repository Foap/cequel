# -*- encoding : utf-8 -*-
require_relative 'spec_helper'

describe 'serialization' do
  model :Post do
    key :blog_subdomain, :text
    key :id, :uuid, auto: true
    column :title, :text
    column :body, :text
  end

  uuid :id

  let(:attributes) do
    {
      blog_subdomain: 'big-data',
      id: id,
      title: 'Cequel',
    }
  end

  let(:post){ Post.new(attributes) }

  before :each do
    Post.include_root_in_json = false
  end

  # Asserted through `to_json` rather than `as_json` because ActiveModel 6.0
  # changed what `as_json` returns: 5.2 handed back a hash still holding live
  # objects, 6.0 runs `.as_json` over it so the hash is JSON-ready. The encoded
  # output is byte-identical on both, so the round-trip is the version-stable
  # assertion — and it is what "JSON serialization" actually means here.
  it 'should provide JSON serialization' do
    json = JSON.parse(post.to_json).symbolize_keys
    expect(json).to eq(attributes.merge(body: nil).as_json.symbolize_keys)
  end

  it 'should be able to serialize restricting to some attributes' do
    json = JSON.parse(post.to_json(only: [:id])).symbolize_keys
    expect(json).to eq(id: attributes[:id].as_json)
  end
end
