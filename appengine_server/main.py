from __future__ import print_function
import webapp2
import json
import os
from datetime import timedelta

from google.appengine.ext.webapp import template, util
from google.appengine.ext import ndb


class Reading(ndb.Model):
    date = ndb.DateTimeProperty(auto_now_add=True, indexed=False)
    name = ndb.TextProperty(indexed=False, default='')
    data = ndb.TextProperty(indexed=False, default='')


class MainPage(webapp2.RequestHandler):
    def post(self, tname):
        data = json.loads(self.request.body)
        dat = Reading(name=tname, data=json.dumps(data))
        dat.put()

    def get(self, tname):
        """reading every 10 minutes of temperature (C) and humidity (RH)"""
        MIN, N = 10, 10 # take the median, percentiles of N readings
        datastr = []
        for d in Reading.query():
            cname = d.name
            cdate = d.date - timedelta(hours=8) # timezones are a major pain in appengine
            th = json.loads(d.data)
            ts = [_t*1.8+32 for _t in th[-2::-2]] # C to F
            hs = th[-1::-2]
            for n in range(0, len(ts), N):
                tn = ts[n:n+N]
                tn.sort()
                t_med = tn[len(tn)//2]
                t1, t9 = tn[0], tn[-1]
                
                hn = hs[n:n+N]
                hn.sort()
                h_med = hn[len(hn)//2]
                h1, h9 = hn[0], hn[-1]
                
                datastr.append("{n:'%s',date:new Date('%s'),t:%s,h:%s,t_ci_down:%s,t_ci_up:%s,h_ci_down:%s,h_ci_up:%s}," %
                    (cname, cdate, t_med, h_med, t1, t9, h1, h9))

                cdate = cdate - timedelta(minutes=MIN*N)
        
        path = os.path.join(os.path.dirname(__file__), "index.html")
        index = template.render(path, {'data': '[' + '\n'.join(sorted(datastr)).rstrip(',') + ']'})
        self.response.out.write(index)


app = webapp2.WSGIApplication([
    ('/([^/]*)', MainPage),
], debug=True)
