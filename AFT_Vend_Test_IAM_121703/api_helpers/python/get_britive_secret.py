import boto3
import logging
from botocore.exceptions import ClientError

logging.basicConfig(level=logging.DEBUG)  # Set the logging level

if __name__ == "__main__":
    # Replace with your specific values
    role_arn = 'arn:aws:iam::198778163183:role/AWSAFTExecution'
    secret_name = "Britive"
    region_name = "us-east-2"

    def assume_role(role_arn, role_session_name='AssumedRoleSession'):
        """
        Assumes the specified role and returns the temporary credentials.
        """
        sts_client = boto3.client('sts')

        try:
            response = sts_client.assume_role(
                RoleArn=role_arn,
                RoleSessionName=role_session_name
            )

            credentials = response['Credentials']
            return credentials

        except ClientError as e:
            print(f"Error assuming role: {e}")
            return None

    def get_secret(secret_name, region_name='us-east-2'):
        """
        Retrieves the specified secret from AWS Secrets Manager.
        """
        # Use the assumed role credentials
        credentials = assume_role(role_arn)
        if not credentials:
            return None

        session = boto3.session.Session()
        secrets_client = session.client(
            service_name='secretsmanager',
            region_name=region_name,
            aws_access_key_id=credentials['AccessKeyId'],
            aws_secret_access_key=credentials['SecretAccessKey'],
            aws_session_token=credentials['SessionToken']
        )

        try:
            response = secrets_client.get_secret_value(SecretId=secret_name)
            secret_value = response['SecretString']
            return secret_value

        except ClientError as e:
            print(f"Error retrieving secret: {e}")
            return None

    secret_value = get_secret(secret_name)

    if secret_value:
        print(f"The secret value is: {secret_value}")
    else:
        print("Failed to retrieve the secret.")
