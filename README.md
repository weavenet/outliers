[![Build Status](https://secure.travis-ci.org/brettweavnet/outliers.png)](http://travis-ci.org/brettweavnet/outliers)

# Outliers

Outliers is a framework for verifying configuration of resources.

## Overview

* Applications and teams rely on multiple service providers (AWS, etc).
* Providers deliver like resources with complex configuration (EC2 Instances, S3 Buckets, etc).
* Resource configuration can be verified (launched from given AMI, contain private objects, etc).
* Resources can be targeted or excluded by their ID (Instance ID, Object Key, etc).
* Resources can be targeted or excluded by matching a filter (Instance has tag 'x' with value 'y').
* Those not passing verifications, are flagged as Outliers.

## Requirements

* Ruby 1.9.3 or greater.

## Installation

Install the gem:

    gem install outliers

## Setup

**Currently Outliers only supports AWS**

Create **~/outliers.yml** with a list of credentials in the following format:

    credential_name:
      key1: value1
      key2: value2

Multiple accounts can be specified, to add a prod and preprod AWS account:

    aws_pre_prod:
      region: us-east-1
      access_key_id: YYY
      secret_access_key: XXX

    aws_prod:
      region: us-east-1
      access_key_id: AAA
      secret_access_key: BBB

Depending on the provider, different keys and values are required.

For a list of providers:

    outliers providers

## Usage

Outliers can be used in two modes, as a **CLI** or a **DSL**.

The CLI is good for testing and quick verifications.

The DSL can be used to build up comprehensive list of verifications for a project or company.

### CLI

To verify all EC2 instances are in a VPC:

    outliers evaluate -c aws_prod -p aws_ec2 -r instance -v vpc

Credential keys can be overriden. To specify region us-west-1.

    outliers evaluate -c aws_prod -p aws_ec2 -r instance -v vpc -c region=us-west-1

Verifications may require arguments. To verify your RDS databases have a 2 day retention period:

    outliers evaluate -c aws_prod -p aws_rds -r db_instance -v backup_retention_period -a days=2

Verifications may accept multiple values for an argument. Values are separated by commas.

To verify EC2 instances are launched from a list of known images:

    outliers evaluate -c aws_prod -p aws_ec2 -r instance -v valid_image_id -a image_ids=ami-12345678,ami-87654321

To only target a specific resource:

    outliers evaluate -c aws_prod -p aws_ec2 -r instance -t i-87654321

To exclude resources that are known exceptions:

    outliers evaluate -c aws_prod -p aws_ec2 -r instance -e i-12345678

Resources have attributes which can be used to filter target resources. To filter instances who have tag 'Name' equal to 'web'.

    outliers evaluate -c aws_prod -p aws_ec2 -r instance -f 'tag=Name:web'

### DSL

To run Outliers as a DSL

* Create a directory to store your evaluations. 
* Evalutions are read from from files within the directory.
* All files ending in **.rb** will be processed.
* Each file can have one or more evaluation blocks. 

To process a directory:

    outliers process -d /home/user/outliers

To verify all instances are in a VPC, create the file **ec2.rb** and add the following block:

    evaluate do
      connect 'aws_prod', provider: 'aws_ec2'
      resources 'instance'
      verify 'vpc'
    end

Files can have multiple evaluations, to add a validation that overrides the region:

    evaluate do
      connect 'aws_prod', provider: 'aws_ec2'
      resources 'instance'
      verify 'vpc'
    end

    evaluate do
      connect 'aws_prod', provider: 'aws_ec2', region: 'us-west-1'
      resources 'instance'
      verify 'vpc'
    end

The DSL supports any valid Ruby code. To iterate over multiple regions:

    ['us-west-1', 'us-west-2', 'us-east-1'].each do |region|
      evaluate do
        connect 'aws_prod', provider: 'aws_ec2', region: region
        resources 'instance'
        verify 'vpc'
      end
    end

Evaluations can run multiple verifications. To validate instances are in a VPC, running and using a valid image:

    evaluate do
      connect 'aws_prod', provider: 'aws_ec2', region: 'us-west-1'
      resources 'instance'
      verify 'vpc'
      verify 'running'
      verify 'valid_image_id', image_ids: ['ami-12345678','ami-87654321']
    end

Evaluations can be given names to help identify Outliers in results.

    evaluate "validate_database_retention_period" do
      connect 'aws_prod', provider: 'aws_rds', region: 'us-west-1'
      resources 'db_instance'
      verify 'backup_retention_period', days: 2
    end

To pass arguments to a verification:

    evaluate do
      connect 'aws_prod', provider: 'aws_rds', region: 'us-west-1'
      resources 'db_instance'
      verify 'backup_retention_period', days: 2
    end

To pass multiple arguments, specify them as an array:

    evaluate do
      connect 'aws_prod', provider: 'aws_ec2', region: 'us-west-1'
      resources 'instance'
      verify 'valid_image_id', image_ids: ['ami-12345678','ami-87654321']
    end

To only target a specific resource:

    evaluate do
      connect 'aws_prod', provider: 'aws_ec2', region: 'us-west-1'
      resources 'instance', 'i-12345678'
      verify 'valid_image_id', image_ids: ['ami-12345678','ami-87654321']
    end

To target multiple resources, you can pass an array:

    evaluate do
      connect 'aws_prod', provider: 'aws_ec2', region: 'us-west-1'
      resources 'instance', ['i-12345678', 'i-abcdef12']
      verify 'valid_image_id', image_ids: ['ami-12345678','ami-87654321']
    end

Sometimes you want to exclude resources that are known exceptions, to exclude an instance from the VPC validation:

    evaluate do
      connect 'aws_prod', provider: 'aws_ec2', region: 'us-west-1'
      resources 'instance'
      exclude 'i-12345678'
      verify 'valid_image_id', image_ids: ['ami-12345678','ami-87654321']
    end

Resources have attributes which can be used to filter target resources. To filter instances who have tag 'Name' equal to 'web'.

    evaluate do
      connect 'aws_prod', provider: 'aws_ec2', region: 'us-west-1'
      resources 'instance'
      filter tag: 'Name:web'
      verify 'valid_image_id', image_ids: ['ami-12345678','ami-87654321']
    end

### Help

For a list of providers and required credentials:

    outliers providers

For a list of resources, and available verifications, for a given provider:

    outliers resources -p PROVIDER_NAME

For a fule list of commands run:

    outliers -h

For full help on a command, append -h:

    outliers evaluate -h

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
