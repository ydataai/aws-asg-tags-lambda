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
    - Name: "A Tag"
      Value: "A value for the tag"
    NodePools:
    - Name: "A node pool name"
      Tags:
      - Name: "Another Tag"
        Value: "A value for another tag"
    - Name: "Another pool name"
      Tags:
      - Name: "Another Tag"
        Value: "A value for another tag"

```


## TODO
- [ ] Tests
- [ ] Better Documentation
- [ ] Support other methods of usage


## About 👯‍♂️

With ❤️ from [YData](https://ydata.ai) [Development team](mailto://developers@ydata.ai)
