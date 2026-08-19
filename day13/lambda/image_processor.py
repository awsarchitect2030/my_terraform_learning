import boto3
import os
from PIL import Image
from io import BytesIO
from urllib.parse import unquote_plus

s3 = boto3.client("s3")

PROCESSED_BUCKET = os.environ["PROCESSED_BUCKET"]


def lambda_handler(event, context):

    print("Lambda started")
    print("Event:", event)

    upload_bucket = event["Records"][0]["s3"]["bucket"]["name"]

    object_key = unquote_plus(
        event["Records"][0]["s3"]["object"]["key"]
    )

    print("Input bucket:", upload_bucket)
    print("Input file:", object_key)

    response = s3.get_object(
        Bucket=upload_bucket,
        Key=object_key
    )

    print("File downloaded from S3")

    image_data = response["Body"].read()

    image = Image.open(BytesIO(image_data))

    print("Image opened:", image.format, image.size)

    print("Converting image to RGB")

    image = image.convert("RGB")

    print("Image converted to RGB")

    png_buffer = BytesIO()

    print("Saving image as PNG")

    image.save(png_buffer, format="PNG")

    print("PNG created successfully")

    png_buffer.seek(0)

    output_key = os.path.splitext(object_key)[0] + ".png"

    print("Uploading:", output_key)
    print("Output bucket:", PROCESSED_BUCKET)

    s3.put_object(
        Bucket=PROCESSED_BUCKET,
        Key=output_key,
        Body=png_buffer.getvalue(),
        ContentType="image/png"
    )

    print("PNG uploaded successfully")

    return {
        "statusCode": 200,
        "body": f"Image converted successfully: {output_key}"
    }