**TheNewFriends** is an online service for getting user contacts data, such as:

- first name
- last name
- skype
- twitter id
- instagram id
- cell phone number

TheNewFriends works with VK social network (sources: groups' members and users' friends) and save them in two separate files: xlsx (Excel Microsoft Office), vcf (Variant Call Format, only skypes)

## Installation

Create file `.env` in the root directory and add **amazon s3 credentials**

```
AWS_ACCESS_KEY_ID=*****
AWS_SECRET_ACCESS_KEY=*****
AWS_REGION=*****
AWS_S3_BUCKET=******
```
