from auth import exchange_code_for_token, authenticate

src="https://apis.google.com/js/platform.js"
#<script src="https://apis.google.com/js/platform.js" async defer></script>

#google sign in button:
#<div class="g-signin2" data-onsuccess="onSignIn"></div>

#Scope = https://www.googleapis.com/auth/userinfo.email
    #try:
    # Specify the CLIENT_ID of the app that accesses the backend:
      #  idinfo = id_token.verify_oauth2_token(access_token, requests.Request(), CLIENT_ID)

    # Or, if multiple clients access the backend server:
    # idinfo = id_token.verify_oauth2_token(token, requests.Request())
    #if idinfo['iss'] not in ['account', CLIENT_ID_2, CLIENT_ID_3]:
    #     raise ValueError('Could not verify audience.')

    # If the request specified a Google Workspace domain
    # if idinfo['hd'] != DOMAIN_NAME:
    #     raise ValueError('Wrong domain name.')

    # ID token is valid. Get the user's Google Account ID from the decoded token.
      #  userid = idinfo['sub']
    #except ValueError:
    # Invalid token
     #   pass

# (Receive token by HTTPS POST)


    #SIGN IN

    #SIGN OUT


class AuthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed_url = urlparse(self.path)
        params = parse_qs(parsed_url.query)

        if parsed_url.path == '/login':
            auth_url = f"https://accounts.google.com/o/oauth2/v2/auth?response_type=code&client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}&scope=email"
            self.send_response(302)
            self.send_header('Location', auth_url)
            self.end_headers()

        elif parsed_url.path == '/callback':
            code = params.get('code', [None])[0]
            if code:
                self.send_response(200)
                self.send_header('Content-type', 'text/html')
                self.end_headers()
                #self.wfile.write(b'<html><body>Successfully authenticated! You can close this window now.</body></html>')

                access_token = exchange_code_for_token(code)
                user_info = authenticate(access_token)
                if user_info:
                    print('User Info:', user_info)
                else:
                    print('Authentication failed.')
