#!/usr/bin/env python
import jwt
import json
import argparse

def encode(data, key, alg="HS256", headers=""):
    return jwt.encode(data, key, algorithm=alg,headers=headers)

def decode(token, secret=None):
    headers = jwt.get_unverified_header(token)
    verified = False
    signature = "Unvalidated"

    if secret:
        try:
            data = jwt.decode(token,secret)
            verified = True
            signature = "Verified"
        except Exception as e:
            data = jwt.decode(token, verify=False)
            signature = e

    if not verified:
        data = jwt.decode(token, verify=False)

    return headers, data, signature

def main(args):
    if args.function == "decode":
        h,d,s = decode(args.value, args.secret)
        print "Headers: %s" % json.dumps(h)
        print "Data: %s" % json.dumps(d)
        print "Signature: %s" % s
    elif args.function == "encode":
        if args.secret or args.alg == "none":
            data = json.loads(args.value)
            encoded = encode(data, args.secret, args.alg, args.headers)
            print "Token: %s" % encoded
        else:
            parser.error("--secret is required when encoding.")
    else:
        parser.error("Invalid function")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("function", type=str, help="encode | decode")
    parser.add_argument("--secret", type=str, help="secret [Mandatory to encode]")
    parser.add_argument("--alg", type=str, default="HS256", help="Algorithm")
    parser.add_argument("--headers", type=str, default="", help="Additional Headers")
    parser.add_argument("value", type=str, help="data to encode | token to decode")
    args = parser.parse_args()
    main(args)

