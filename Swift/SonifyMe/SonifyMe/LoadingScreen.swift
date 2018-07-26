import UIKit
import AVKit
import Foundation
import AudioToolbox

class LoadingScreen : ViewController {
    var inputLocation = ""
    var inputDate = ""
    var inputTime = ""
    var inputDuration = ""
    var initData : [Float64] = [Float64]()

    func isNumber(num:String) -> Bool {
        var theNum = ""
        if (num[num.startIndex] == "-") {
            theNum = String(num[num.index(num.startIndex, offsetBy: 1)..<num.endIndex])
        } else {
            theNum = num
        }
        let numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        if (!numbers.contains(String(theNum[num.index(num.startIndex, offsetBy: 0)]))) {return false}
        if (String(theNum[num.index(num.startIndex, offsetBy: 1)]) != ".") {return false}
        return true
    }
    
    func getSoundAndGraph(locate:String, date:String, time:String, duration:String, AF:String, FA:String) -> [Float64] {
        let halfpi = 0.5*Double.pi
        let duration = String(Float64(duration)! * 3600)
        //let disploc = locate
        let time = time + ":00"
        
        var soundname = ""
        var station = ""
        var net = ""
        var location = ""
        var channel = ""
        switch locate {
            case "Yellowstone (WY,USA)":
                soundname = "yellowstone"
                station = "H17A"
                net = "TA"
                location = "--"
                channel = "BHZ"
                break
            case "Anchorage (AK,USA)":
                soundname = "alaska"
                station = "SSN"
                net = "AK"
                location = "--"
                channel = "BHZ"
                break
            case "London, UK":
                soundname = "london"
                station = "HMNX"
                net = "GB"
                location = "--"
                channel = "BHZ"
                break
            case "Kyoto, Japan":
                soundname = "japan"
                station = "JWT"
                net = "JP"
                location = "--"
                channel = "BHZ"
                break
            case "Cachiyuyo, Chile":
                soundname = "chile"
                station = "LCO"
                net = "IU"
                location = "10"
                channel = "BHZ"
                break
            case "Ar Rayn, Saudi Arabia":
                soundname = "saudiarabia"
                station = "RAYN"
                net = "II"
                location = "10"
                channel = "BHZ"
                break
            case "Antarctica":
                soundname = "antarctica"
                station = "BELA"
                net = "AI"
                location = "04"
                channel = "BHZ"
                break
            default:
                soundname = "ryerson"
                station = "L44A"
                net = "TA"
                location = "--"
                channel = "BHZ"
                print("Defaulting to Ryerson Station...")
                break
        }
        print(soundname)
        
        let type = net + "&sta=" + station + "&loc=" + location + "&cha=" + channel
        let when = "&starttime=" + date + "T" + time + "&duration=" + duration
        let url = "https://service.iris.edu/irisws/timeseries/1/query?net=" + type + when + "&demean=true&scale=auto&output=ascii1"
        let Url = URL(string: url)
        var df = ""
        do {
            df = try String(contentsOf: Url!)
        } catch {
            print("Invalid URL")
        }
        let dflines = df.split(separator: "\n")
        
        let head = dflines[0]
        let fsps = Float64(head.split(separator: " ")[4])
        var tot = Float64(head.split(separator: " ")[2])
        var sound = [Float64]()
        var maxAmp = 0.0
        for i in 1..<dflines.count {
            if (isNumber(num: String(dflines[i]))) {
                let f = Float64(dflines[i])
                sound.append(f!)
                maxAmp = max(maxAmp, abs(f!))
            } else {
                tot = tot! + Float64(dflines[i].split(separator: " ")[2])!
            }
        }
        
        let frequencies : [String : Float64] = ["0.1 Hz" : 64000.0,
                                                "0.5 Hz" : 16000.0,
                                                "5 Hz" : 1600.0,
                                                "10 Hz" : 800.0,
                                                "50 Hz" : 160.0]
        var bandsHZ = frequencies[AF]
        if (bandsHZ == nil) {bandsHZ = 400.0}
        
        var fixedamp: Float64
        if (FA == "") {
            fixedamp = maxAmp / 3
        } else {
            fixedamp = Float64(FA)!
        }
        
        let realduration = (tot!/fsps!)/3600
        var hours = [Float64]()
        var marker = 0.0
        let increment = realduration / tot!
        while (marker < realduration) {
            hours.append(marker)
            marker = marker + increment
        }
        //let soundduration = tot!/(fsps!*bandsHZ)
        //let mxs = 1.01*Double(maxAmp)
        //let mns = 0.0
        var s32 = [Float64]()
        for ii in 0..<sound.count {
            s32.append(Float64((2^31))*atan(sound[ii]/fixedamp)/halfpi)
        }
        
        let ssps = bandsHZ! * fsps!
        saveFile(buff: s32, sample_rate: ssps)
        /*axes(xlim=[0,realduration], ylim=[1000*mns,1000*mxs], xlabel="Time since "+time+ " (hours)",ylabel="Ground Velocity (mm/s)", title=locate+", "+date)
         plot(hours,1000.*sound)
         axishours = [time]
         axis([hours[0],hours[-1],-3000.*fixedamp,3000.*fixedamp])
         savefig(soundname + ".png",bbox_inches="tight")*/
        
        return s32
    }
    
    func saveFile(buff: [Float64], sample_rate: Float64) {
        let SAMPLE_RATE = sample_rate
        
        let outputFormatSettings = [
            AVFormatIDKey:kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey:32,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMIsBigEndianKey: false,
            AVSampleRateKey: SAMPLE_RATE,
            AVNumberOfChannelsKey: 1
            ] as [String : Any]
        
        let audioFile = try? AVAudioFile(forWriting: url!, settings: outputFormatSettings, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: false)
        
        let bufferFormat = AVAudioFormat(settings: outputFormatSettings)
        let outputBuffer = AVAudioPCMBuffer(pcmFormat: bufferFormat!, frameCapacity: AVAudioFrameCount(buff.count))
        for i in 0..<buff.count {outputBuffer!.floatChannelData!.pointee[i] = Float(buff[i])}
        outputBuffer?.frameLength = AVAudioFrameCount(buff.count)
        
        do {
            try audioFile?.write(from: outputBuffer!)
        } catch {
            print("Error writing audio file")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if ((segue.destination as? DisplayScreen) != nil) {
            let displayScreen = segue.destination as? DisplayScreen
            displayScreen?.data = initData
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        initData = self.getSoundAndGraph(locate: inputLocation, date: inputDate, time: inputTime, duration: inputDuration, AF: "", FA: "")
        performSegue(withIdentifier: "ToDisplay", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
