[![Build Status](https://secure.travis-ci.org/brettweavnet/outliers.png)](http://travis-ci.org/brettweavnet/outliers)
[![Code Climate](https://codeclimate.com/github/brettweavnet/outliers.png)](https://codeclimate.com/github/brettweavnet/outliers)

# Outliers

A framework to detect misconfigurations (Outliers).

## Overview

To detect misconfigurations at scale, Outliers provides a framework for performing complex evaluations of cloud resources based on the following:

* Applications rely on **resources** delivered from multiple **providers** (EC2, S3, etc).
* Resource configuration can be evaluated against specific **verifications**  (Instance launched from given AMI, S3 bucket contains no public objects, etc).
* Verifications can be performed against a subset of resources based on a **filter**.
* Those not passing verification, are flagged as Outliers.

## Requirements

* Ruby 1.9.3 or greater

## Installation

    gem install outliers

## Getting Started

Create **~/outliers.yml** with a list of accounts in the following format:

    account_name:
      region: AWS_REGION
      access_key_id: AWS_ACCESS_ID
      secret_access_key: AWS_SECRET_KEY

For example:

    aws_prod:
      region: us-east-1
      access_key_id: abcd1234abcd1234abcd
      secret_access_key: abcd1234abcd1234abcdabcd1234abcd1234abcd

Create a directory to store your evaluations.

    mkdir ~/outliers

To verify all instances in aws_prod are in a VPC, create ec2.rb in ~/outliers containing:

    evaluate do
      connect 'aws_prod', provider: 'aws_ec2'
      resources 'instance'
      verify 'vpc'
    end

Run outliers against the directory:

    outliers process -d ~/outliers

Sample Output:

    I, [2013-09-24T09:42:39.925400 #4940]  INFO -- : Processing '~/outliers/ec2.rb'.
    I, [2013-09-24T09:42:39.925657 #4940]  INFO -- : Connecting via 'aws_prod' to 'aws_ec2'.
    I, [2013-09-24T09:42:39.925703 #4940]  INFO -- : Including connection options 'provider=aws_ec2,region=us-east-1'.
    I, [2013-09-24T09:42:39.928945 #4940]  INFO -- : Loading 'instance' resource collection.
    D, [2013-09-24T09:42:39.929015 #4940] DEBUG -- : Connecting to region 'us-east-1'.
    I, [2013-09-24T09:42:41.192295 #4940]  INFO -- : Verifying 'vpc?'.
    D, [2013-09-24T09:42:41.192498 #4940] DEBUG -- : Target resources 'i-abcd0001, i-abcd0002, i-abcd0003, i-abcd0004'.
    D, [2013-09-24T09:42:41.476478 #4940] DEBUG -- : Verification of resource 'i-abcd0001' passed.
    D, [2013-09-24T09:42:42.025429 #4940] DEBUG -- : Verification of resource 'i-abcd0002' passed.
    D, [2013-09-24T09:42:42.278990 #4940] DEBUG -- : Verification of resource 'i-abcd0003' passed.
    D, [2013-09-24T09:42:44.803911 #4940] DEBUG -- : Verification of resource 'i-abcd0004' passed.
    I, [2013-09-24T09:42:44.804036 #4940]  INFO -- : Verification 'vpc?' passed.
    I, [2013-09-24T09:42:44.804147 #4940]  INFO -- : Evaluations completed.
    I, [2013-09-24T09:42:44.804211 #4940]  INFO -- : (0 evaluations failed, 1 evaluations passed.)

## Examples

See [examples](http://www.getoutliers.com/documentation/examples) for a list of more advanced evaluations.

## References

See [providers](http://www.getoutliers.com/documentation/providers), [resources](http://www.getoutliers.com/documentation/resources) and [filters](http://www.getoutliers.com/documentation/filters) for additional documentation.
