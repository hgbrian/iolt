from __future__ import print_function
import webapp2
import json
from google.appengine.ext import ndb


class Reading(ndb.Model):
    date = ndb.DateTimeProperty(auto_now_add=True, indexed=False)
    data = ndb.TextProperty(indexed=False, default='')


class MainPage(webapp2.RequestHandler):
    def post(self):
        data = json.loads(self.request.body)
        dat = Reading(data=json.dumps(data))
        dat.put()
        #else:
        #    print("no temperature")
        #self.response.headers['Content-Type'] = 'text/plain'
        #self.response.write('Hello, World!')


app = webapp2.WSGIApplication([
    ('/', MainPage),
], debug=True)
