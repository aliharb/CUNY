#!/usr/bin/env python

import hashlib
import time
import urllib #for url encoding
import urllib2 #for sending requests
import base64
import datetime
from datetime import date, timedelta
import clearbit
from clearbit import Enrichment as cb_enc
import calendar
import pandas as pd
import json
import gspread
from oauth2client.client import SignedJwtAssertionCredentials
import traceback
import sys

clearbit.key = '906cf0605ba68c6dfc2a331f1a552b96'
email_list = []


# # Get users!

# In[25]:



try:
    import json
except ImportError:
    import simplejson as json

class Mixpanel(object):

   def __init__(self, api_key, api_secret, token):
       self.api_key = api_key
       self.api_secret = api_secret
       self.token = token

   def request(self, params, format = 'json'):
       '''let's craft the http request'''
       params['api_key']=self.api_key
       params['expire'] = int(time.time())+600 # 600 is ten minutes from now
       if 'sig' in params: del params['sig']
       params['sig'] = self.hash_args(params)

       request_url = 'http://mixpanel.com/api/2.0/engage/?' + self.unicode_urlencode(params)

       request = urllib.urlopen(request_url)
       data = request.read()

       #print request_url

       return data

   def hash_args(self, args, secret=None):
       '''Hash dem arguments in the proper way
       join keys - values and append a secret -> md5 it'''

       for a in args:
           if isinstance(args[a], list): args[a] = json.dumps(args[a])

       args_joined = ''
       for a in sorted(args.keys()):
           if isinstance(a, unicode):
               args_joined += a.encode('utf-8')
           else:
               args_joined += str(a)

           args_joined += "="

           if isinstance(args[a], unicode):
               args_joined += args[a].encode('utf-8')
           else:
               args_joined += str(args[a])

       hash = hashlib.md5(args_joined)

       if secret:
           hash.update(secret)
       elif self.api_secret:
           hash.update(self.api_secret)
       return hash.hexdigest()

   def unicode_urlencode(self, params):
       ''' Convert stuff to json format and correctly handle unicode url parameters'''

       if isinstance(params, dict):
           params = params.items()
       for i, param in enumerate(params):
           if isinstance(param[1], list):
               params[i] = (param[0], json.dumps(param[1]),)

       result = urllib.urlencode([(k, isinstance(v, unicode) and v.encode('utf-8') or v) for k, v in params])
       return result


# In[26]:

# Secret Stuff!
api = Mixpanel(
    api_key = 'a44c33645f6868776261a18b2bf2d746',
    api_secret = 'f8f3514e18b8963488e058d7457e9a6d',
    token = 'ad6df61d0b9400400b240631576c24d4'
)
'''Here is the place to define your selector to target only the users that you're after'''
'''parameters = {'selector':'(properties["$email"] == "Albany") or (properties["$city"] == "Alexandria")'}'''

yesterday = datetime.date(2016, 8, 2)
yesterday = yesterday.strftime("%s")
today = datetime.datetime.utcnow().strftime("%s")

parameters = {'selector': '(datetime('+yesterday+') < properties["date_joined"]     and not ".org" in properties["$email"] and not ".net" in properties["$email"]     and not".edu" in properties["$email"] and not"k12" in properties["$email"]     and not"schools" in properties["$email"])'}
print parameters
response = api.request(parameters)

try:
    parameters['session_id'] = json.loads(response)['session_id']
except:
    print json.loads(response)

parameters['page']=0
global_total = json.loads(response)['total']

print "Session id is %s \n" % parameters['session_id']
print "Here are the # of people %d" % global_total
fname = "output_people.txt"
has_results = True
total = 0
with open(fname,'w') as f:
    while has_results:
        responser = json.loads(response)['results']
        total += len(responser)
        has_results = len(responser) == 1000
        for data in responser:
            email_list.append( data['$properties']['$email'] )
            #f.write(data['$properties']['$email']+'\n')
        print "%d / %d" % (total,global_total)
        parameters['page'] += 1
        if has_results:
            response = api.request(parameters)


# In[ ]:

if email_list == []:
    print "no emails found"
    sys.exit("no emails found")


# # Call Clearbit

# In[3]:

users = {}
for em in email_list:
    if em != '' and '@' in em:
        users[em] = {}
        try:
            resp = cb_enc.find(email=em,stream=True)
        except:
            print 'error finding email ', em
            print traceback.print_exc()
        try:
            users[em]['company'] = resp['person']['employment']['name']
        except:
            pass
        try:
            users[em]['title'] = resp['person']['employment']['title']
        except:
            pass
        try:
            users[em]['full_name'] = resp['person']['name']['fullName']
        except:
            pass
        try:
            users[em]['sector'] = resp['company']['category']['sector']
        except:
            pass
        try:
            users[em]['employees'] = resp['company']['metrics']['employees']
        except:
            pass
        try:
            users[em]['phone_numbers'] = resp['company']['site']['phoneNumbers']
        except:
            pass
        try:
            users[em]['country'] = resp['person']['geo']['country']
        except:
            pass
        try:
            users[em]['city'] = resp['person']['geo']['city']
        except:
            pass


# In[ ]:

if users == {}:
    sys.exit("no users found")


# In[4]:

print users


# # Sort in Pandas

# In[5]:

df = pd.DataFrame.from_dict(users).transpose().reset_index()


# In[8]:

df.head()


# In[9]:

df = df.sort_values(['company'],ascending=[1])


# In[10]:

df_list = df.values.tolist()


# In[11]:

cols = list(df.columns)
cols = [ ea.upper() for ea in cols ]
cols.pop(0)
cols.insert(0,'EMAIL')
cols


# In[12]:

df_list.insert(0,cols)


# In[13]:

print df_list[0:3]
