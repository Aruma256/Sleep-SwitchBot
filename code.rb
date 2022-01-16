require "json"
require "net/http"
require "webrick"

token = ARGV[0]
$header = {
    "Content-Type": "application/json; charset=utf8",
    "Authorization": token,
}

device_id = ARGV[1]
$uri = URI.parse("https://api.switch-bot.com/v1.0/devices/#{device_id}/commands")

def post(command)
    Net::HTTP.post($uri, {"command": command}.to_json, $header)
end

class MyServlet < WEBrick::HTTPServlet::AbstractServlet
    def do_POST(req, res)
        case JSON.load(req.body)["event"].to_sym
        when :sleep_tracking_started
            post("turnOff")
        when :sleep_tracking_stopped
            post("turnOn")
        end
    end
end

srv = WEBrick::HTTPServer.new({BindAddress: "0.0.0.0", Port: 22559})
srv.mount("/", MyServlet)
trap("INT"){ srv.shutdown }
srv.start
