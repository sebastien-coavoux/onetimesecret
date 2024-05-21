# frozen_string_literal: true
#
require_relative '../lib/onetime'

# Use the default config file for tests
OT::Config.path = File.join(__dir__, '..', 'etc', 'config.test')
OT.load! :app

## Can create Secret
s = Onetime::Secret.new :private
s.class
#=> Onetime::Secret

## Keys are consistent for Metadata
s = Onetime::Metadata.new :metadata, :entropy
s.rediskey
#=> 'metadata:8ny214nkhk6z0dvn28i9aan0wu175ju:object'

## Keys are consistent for Secrets
s = Onetime::Secret.new :shared, :entropy
p s.name
s.rediskey
#=> 'secret:5qg9u0378yfndeoks7th64vilzuiuak:object'

## But can be modified with entropy
s = Onetime::Secret.new :shared, [:some, :fixed, :values]
s.rediskey
#=> 'secret:2ooz2vmg2n9eewy4v70vliqa9iqeiug:object'

## Generate a pair
@metadata, @secret = Onetime::Secret.spawn_pair :anon, :tryouts
[@metadata.nil?, @secret.nil?]
#=> [false, false]

## Private keys match
!@secret.metadata_key.nil? && @secret.metadata_key == @metadata.key
#=> true

## Shared keys match
!@metadata.secret_key.nil? && @metadata.secret_key == @secret.key
#=> true

## Kinds are correct
[@metadata.class, @secret.class]
#=> [OT::Metadata, OT::Secret]

## Can save a secret
@metadata.save
#=> true

## A saved secret exists
@metadata.exists?
#=> true

## A secret can be destroyed
@metadata.destroy!
#=> 1

## Can set private secret to viewed state
metadata, secret = Onetime::Secret.spawn_pair :anon, :tryouts
metadata.viewed!
[metadata.viewed, metadata.state]
#=> [Time.now.utc.to_i.to_s, 'viewed']

## Can set shared secret to viewed state
metadata, secret = Onetime::Secret.spawn_pair :anon, :tryouts
metadata.save && secret.save
secret.received!
metadata = secret.load_metadata
# NOTE: The secret no longer keeps a reference to the metadata
[metadata.shared, metadata.state, secret.received, secret.state]
##=> [Time.now.utc.to_i.to_s, 'shared', Time.now.utc.to_i.to_s, 'received']
