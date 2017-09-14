import SocketServer
import SimpleHTTPServer
import urllib
import subprocess

PORT = 1234

class Proxy(SimpleHTTPServer.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/ps':
       	    res = subprocess.check_output(['sh', '-c', 'ps -ef'])
            self.wfile.write(res)
            self.wfile.close()
        elif self.path == '/netstat':
       	    res = subprocess.check_output(['sh', '-c', 'netstat -na'])
            self.wfile.write(res)
            self.wfile.close()         
        elif self.path == '/' or self.path == '/index.html':
            self.send_response(200)
            self.send_header("content-type", "text/html")
            self.end_headers()
            self.copyfile(urllib.urlopen('index.html'), self.wfile)
        else:
            self.wfile.write('<div>No such path ' + self.path + '</div>')
            self.wfile.close()

httpd = SocketServer.ForkingTCPServer(('', PORT), Proxy)
print "serving at port", PORT
httpd.serve_forever()
