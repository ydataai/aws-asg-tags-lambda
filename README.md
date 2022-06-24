[![Released](https://img.shields.io/github/v/release/ydataai/aws-asg-tags-lambda?display_name=tag&label=release&logo=github&sort=semver&style=flat-square)](https://github.com/ydataai/aws-asg-tags-lambda/actions/workflows/released.yml)
[![PreReleased](https://img.shields.io/github/v/release/ydataai/aws-asg-tags-lambda?display_name=tag&include_prereleases&label=prerelease&logo=github&sort=semver&style=flat-square)](https://github.com/ydataai/aws-asg-tags-lambda/actions/workflows/prereleased.yml)
[![CI Status](https://img.shields.io/github/workflow/status/ydataai/aws-asg-tags-lambda/Merge%20Main?label=ci&logo=github&style=flat-square)](https://github.com/ydataai/aws-asg-tags-lambda/actions/workflows/merge-main.yml)
[![license](https://img.shields.io/github/license/ydataai/aws-asg-tags-lambda?label=license&style=flat-square)](https://github.com/ydataai/aws-asg-tags-lambda/blob/main/LICENSE)
[![Swift 5.6](https://img.shields.io/badge/Swift-5.6-orange.svg?style=flat-square&logo=swift)](https://developer.apple.com/swift/)

# AWS Auto Scaling Groups Tag lambda

A lambda that add tags to the auto scaling groups of each k8s node.

It's user responsability to specify the cluster the pools and the tags for each pool, or specify it in the common tags, if you want the same tag for each node you want to process.

## How to use

### CloudFormation

The execution role, it's necessary to connect to the EKS and EC2 for the auto scaling groups

```yaml
EKSASGTagLambdaExecutionRole:
  Type: AWS::IAM::Role
  Properties:
    AssumeRolePolicyDocument:
      Version: '2012-10-17'
      Statement:
      - Effect: Allow
        Principal:
          Service:
          - lambda.amazonaws.com
        Action:
        - sts:AssumeRole
    Policies:
    - PolicyName: !Join
        - '-'
        - - 'lambda-asg-tag'
          - !Ref IntegerSuffix
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
        - Effect: Allow
          Action:
          - eks:*
          - ec2:*
          Resource: '*'
    ManagedPolicyArns:
    - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

The declaration of the lambda function, which will be used by the invoke

```yaml
EKSASGTagLambdaFunction:
  Type: AWS::Lambda::Function
  Properties:
    Role: !GetAtt EKSASGTagLambdaExecutionRole.Arn
    PackageType: Image
    Code:
      ImageUri: !Ref EcrImageUri
    Architectures:
    - x86_64
    MemorySize: 1024
    Timeout: 300
```

The lambda invokation

```yaml
EKSASGTagLambdaInvoke:
  Type: AWS::CloudFormation::CustomResource
  DependsOn: EKSASGTagLambdaFunction
  Version: "1.0"
  Properties:
    ServiceToken: !GetAtt EKSASGTagLambdaFunction.Arn
    StackID: !Ref AWS::StackId
    AccountID: !Ref AWS::AccountId
    Region: !Ref AWS::Region
    ClusterName: "the EKS cluster name"
    CommonTags:
    - Name: "ENVIRONMENT"
      Value: "dev"
      PropagateAtLaunch: true
    NodePools:
    - Name: "system-nodepool"
      Tags:
      - Name: 'k8s.io/cluster-autoscaler/node-template/taint/TAINT'
        Value: 'NoSchedule'
        PropagateAtLaunch: true
      - Name: 'k8s.io/cluster-autoscaler/node-template/label/LABEL'
        Value: 'LABEL_VALUE'
        PropagateAtLaunch: true
    - Name: "another-pool"

```

Both `CommonTags` and `Tags` of each NodePool are optional, but if you don't specify `CommonTags` neither `Tags` for each NodePool, it will not do anything.

## TODO
- [ ] Add generic context
- [ ] Tests
- [ ] Better Documentation
- [ ] Support other methods of invocation


## About 👯‍♂️

With ❤️ from [YData](https://ydata.ai) [Development team](mailto://developers@ydata.ai)
