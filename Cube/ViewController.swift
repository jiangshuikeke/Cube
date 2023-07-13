//
//  ViewController.swift
//  Cube
//
//  Created by 陈沈杰 on 2022/12/28.
//

import UIKit
import AVFoundation
import AudioToolbox
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        initView()
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bt = UIButton()
        let locY = touches.first?.location(in: self.view).y
        if locY! <= counterView.frame.minY{
            if !cubePicker0.isHidden && player0MoreOp.isHidden{
                bt.tag = 0
                UIView.animate(withDuration: 0.25) {
                    self.cubePicker0.alpha = 0.0
                }completion: { flag in
                    self.cubePicker0.isHidden = true
                    self.canTouch()
                }
                
            }else if !player0MoreOp.isHidden{
                bt.tag = 0
                UIView.animate(withDuration: 0.25) {
                    self.player0MoreOp.alpha = 0.0
                }completion: { flag in
                    self.player0MoreOp.isHidden = true
                    self.canTouch()
                }
                
            }
        }
        
        if locY! >=  counterView.frame.maxY{
            if !cubePicker1.isHidden && player1MoreOp.isHidden{
                UIView.animate(withDuration: 0.25) {
                    self.cubePicker1.alpha = 0.0
                }completion: { flag in
                    self.cubePicker1.isHidden = true
                    self.canTouch()
                }
                
            }else if !player1MoreOp.isHidden{
                UIView.animate(withDuration: 0.25) {
                    self.player1MoreOp.alpha = 0.0
                }completion: { flag in
                    self.player1MoreOp.isHidden = true
                    self.canTouch()
                }
            }
        }
        
    }
   
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        guard let view = touch.view else{
            return
        }
        
        if !isBegin{
            //开始计时 显示颜色消失
            //对面玩家没有准备的情况下
            if !isReady1 || !isReady0{
                isReady0 = false
                isReady1 = false
            }
            if view != counterView{
                view.backgroundColor = .clear
            }
            start()
        }
        
    }
    
    //MARK: - 变量
    private lazy var player0View:UIView = {
        let view = UIView(frame: CGRect(x: 0, y: isIPhoneX ?48:0, width: ScreenWidth, height: AreaHeight))
        view.addSubview(player0TimeLabel)
        view.addSubview(randomStep0)
        view.addSubview(yieldTime0)
        view.transform = CGAffineTransform(rotationAngle: .pi)
        return view
    }()
    
    private lazy var player0Time:CGFloat = 0.0
    
    private lazy var player0TimeLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: AreaHeight))
        label.textColor = .white
        label.textAlignment = .center
//        label.font = UIFont.systemFont(ofSize: 60)
        label.text = "0.000"
        label.isUserInteractionEnabled = true
        label.font = UIFont(name: "Helvetica", size: 60)
        let tap = UITapGestureRecognizer(target: self, action: #selector(player0Touch(sender:)))
        tap.delegate = self
        label.addGestureRecognizer(tap)
        label.tag = 0
        return label
    }()
    
    private lazy var player1View:UIView = {
        let view = UIView(frame: CGRect(x: 0, y: isIPhoneX ?AreaHeight + 44.0 + 44.0:AreaHeight + 44.0, width: ScreenWidth, height: AreaHeight))
        view.addSubview(player1TimeLabel)
        view.addSubview(randomStep1)
        view.addSubview(yieldTime1)
        return view
    }()
    
    private lazy var player1Time:CGFloat = 0.0
    
    private lazy var player1TimeLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: AreaHeight))
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: "Helvetica", size: 60)
        label.text = "0.000"
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(player1Touch(sender:)))
        tap.delegate = self
        label.addGestureRecognizer(tap)
        label.tag = 1
        return label
    }()
    
    private lazy var counterView:UIView = {
        let view = UIView(frame: CGRect(x: 0, y:isIPhoneX ?AreaHeight + 44.0:AreaHeight, width: ScreenWidth, height: 44.0))
        view.addSubview(player0ScoreLabel)
        view.addSubview(player0MoreButton)
        view.addSubview(player1ScoreLabel)
        view.addSubview(player1MoreButton)
        
        view.backgroundColor = .white.withAlphaComponent(0.2)
        view.isUserInteractionEnabled = true
        starView.center.x = view.center.x
        starView.center.y = 22.0
        starView.isHidden = true
        let bonus = UILongPressGestureRecognizer(target: self, action: #selector(startBonus(sender:)))
        bonus.minimumPressDuration = 0.35
        view.addGestureRecognizer(bonus)
        view.addSubview(starView)
        return view
    }()
    
    private lazy var player0ScoreLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 27.0, y: 0, width: 44, height: 44))
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = "0"
        label.center.y = 22.0
        label.textAlignment = .center
        label.transform = CGAffineTransform(rotationAngle: .pi)
        return label
    }()
    
    private lazy var player0MoreButton:UIButton = {
        let button = UIButton()
        
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "ellipsis")?.withTintColor(.white.withAlphaComponent(0.6), renderingMode: .alwaysOriginal), for: .normal)
        } else {
            let image = UIImage(named: "gengduo")
            button.setImage(image, for: .normal)
        }
        button.transform = CGAffineTransform(rotationAngle:  .pi / 2)
        button.frame.origin.x = 22.0
        button.frame = CGRect(x: 0, y: 0, width: 54, height: 44)
        button.tag = 0
        button.addTarget(self, action: #selector(showMore1(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var player0MoreOp:UIView = {
        let view = UIView(frame: CGRect(x: 0, y: AreaHeight - opHeight, width: opWidth, height: opHeight))
        view.layer.cornerRadius = 15.0
        view.layer.masksToBounds = true
        view.center = player0View.center
        view.isHidden = true
        view.backgroundColor = .white
        DNFBt0.tag = 0
        switchBt0.tag = 0
        yieldBt0.tag = 0
        remakeBt0.tag = 0
        switchLangBt0.tag = 0
        view.addSubview(DNFBt0)
        view.addSubview(switchBt0)
        view.addSubview(yieldBt0)
        view.addSubview(remakeBt0)
        view.addSubview(switchLangBt0)
        view.transform = CGAffineTransform(rotationAngle: .pi)
        return view
    }()
    
    private lazy var player1ScoreLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: ScreenWidth - 71.0, y: 0, width: 44, height: 44))
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = "0"
        label.textAlignment = .center
        label.center.y = 22.0
        return label
    }()
    
    private lazy var player1MoreButton:UIButton = {
        let button = UIButton()
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "ellipsis")?.withTintColor(.white.withAlphaComponent(0.6), renderingMode: .alwaysOriginal), for: .normal)
        } else {
            button.setImage(UIImage(named: "gengduo"), for: .normal)
        }
        button.transform = CGAffineTransform(rotationAngle:  .pi / 2)
        button.frame = CGRect(x: ScreenWidth - 54.0, y: 0, width: 54, height: 44)
        button.tag = 1
        button.addTarget(self, action: #selector(showMore1(sender:)), for: .touchUpInside)
        return button
    }()
    
    private let opWidth:CGFloat = 258
    private let opHeight:CGFloat = 230.0
    private let opCellHeight:CGFloat = 230 / 5
    private lazy var player1MoreOp:UIView = {
        let view = UIView(frame: CGRect(x: ScreenWidth - 66.0, y: AreaHeight + 44.0, width: opWidth, height: opHeight))
        view.backgroundColor = .white
        view.layer.cornerRadius = 15.0
        view.layer.masksToBounds = true
        view.center = player1View.center
        view.isHidden = true
        DNFBt1.tag = 1
        remakeBt1.tag = 1
        switchBt1.tag = 1
        yieldBt1.tag = 1
        switchLangBt1.tag = 1
        view.addSubview(DNFBt1)
        view.addSubview(remakeBt1)
        view.addSubview(switchBt1)
        view.addSubview(yieldBt1)
        view.addSubview(switchLangBt1)
        return view
    }()
    
    private lazy var DNFBt0:UIButton = DNFButton
    private lazy var DNFBt1:UIButton = DNFButton
    private var DNFButton:UIButton{
        let dnfButton = UIButton(frame: CGRect(x: 0, y: opCellHeight * 2, width: opWidth, height: opCellHeight))
        dnfButton.setTitleColor(.black, for: .normal)
        dnfButton.addTarget(self, action: #selector(DNF(sender:)), for: .touchUpInside)
        dnfButton.setAttributedTitle(NSAttributedString(string: "DNF",attributes: [.font:UIFont.systemFont(ofSize: 16)]), for: .normal)
        dnfButton.addSubview(div)
        dnfButton.setBackgroundImage(getFullColor(color: .lightGray.withAlphaComponent(0.2)), for: .highlighted)
        return dnfButton
    }
    
    private lazy var switchBt0:UIButton = switchType
    private lazy var switchBt1:UIButton = switchType
    private var switchType:UIButton{
        let switchType = UIButton(frame: CGRect(x: 0, y:0 , width: opWidth, height: opCellHeight))
        switchType.setTitleColor(.black, for: .normal)
        switchType.tag = 1
        switchType.addTarget(self, action: #selector(isHiddenCubeTable(sender:)), for: .touchUpInside)
        switchType.addSubview(div)
        switchType.setBackgroundImage(getFullColor(color: .lightGray.withAlphaComponent(0.2)), for: .highlighted)
        return switchType
    }
    
    private lazy var yieldBt0:UIButton = yield
    private lazy var yieldBt1:UIButton = yield
    private var yield:UIButton{
        let yield = UIButton(frame: CGRect(x: 0, y: opCellHeight, width: opWidth, height: opCellHeight))
        yield.tag = 1
        yield.setTitleColor(.black, for: .normal)
        yield.addTarget(self, action: #selector(fieldTime(sender:)), for: .touchUpInside)
        yield.addSubview(div)
        yield.setBackgroundImage(getFullColor(color: .lightGray.withAlphaComponent(0.2)), for: .highlighted)
        return yield
    }
    
    
    private lazy var remakeBt0:UIButton = remake
    private lazy var remakeBt1:UIButton = remake
    private var remake:UIButton{
        let remake = UIButton(frame: CGRect(x: 0, y: opCellHeight * 3, width: opWidth, height: opCellHeight))
        remake.setTitleColor(.black, for: .normal)
        remake.addTarget(self, action: #selector(remakeGame(sender:)), for: .touchUpInside)
        remake.setBackgroundImage(getFullColor(color: .lightGray.withAlphaComponent(0.2)), for: .highlighted)
        remake.addSubview(div)
        return remake
    }
    
    
    private lazy var switchLangBt0:UIButton = switchLang
    private lazy var switchLangBt1:UIButton = switchLang
    private var switchLang:UIButton{
        let bt = UIButton(frame: CGRect(x: 0, y: opCellHeight * 4, width: opWidth, height: opCellHeight))
        bt.setTitleColor(.black, for: .normal)
        bt.addTarget(self, action: #selector(switchLang(sender:)), for: .touchUpInside)
        return bt
    }
    
    private var div:UIView{
        let div = UIView(frame: CGRect(x: 0, y: opCellHeight - 1, width: opWidth, height: 1))
        div.backgroundColor = .lightGray.withAlphaComponent(0.1)
        return div
    }
    private let AreaHeight:CGFloat = isIPhoneX ?(ScreenHeight - 44.0 - 78.0) / 2:(ScreenHeight - 44.0) / 2
    
    private var count = 0
    private var dispalyColor:UIColor = .red
    
    private var isPlaying0:Bool = false
    private var isPlaying1:Bool = false
    private var isReady0:Bool = false
    private var isReady1:Bool = false
    private lazy var randomManager:RandomManager = RandomManager.shared
    
    private var link:CADisplayLink?
    private var counter:CADisplayLink{
        let link = CADisplayLink(target: self, selector: #selector(counter(sender:)))
        return link
    }
    
    private var score0 = 0
    private var score1 = 0
    private var player0Selected:Int = 1
    private var player1Selected:Int = 1
    
    private lazy var randomStep0:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 32, width: ScreenWidth, height: 88))
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        
        label.preferredMaxLayoutWidth = ScreenWidth - 48
        label.numberOfLines = 0
        label.sizeToFit()
        label.frame.size.width = ScreenWidth
        return label
    }()
    
    private lazy var randomStep1:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 32, width: ScreenWidth, height: 0))
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.preferredMaxLayoutWidth = ScreenWidth - 48
        
        label.numberOfLines = 0
        label.frame.size.width = ScreenWidth
        return label
    }()
    
    private lazy var yieldTime0:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: AreaHeight / 2 + 54, width: ScreenWidth, height: 44))
        label.center.x = view.center.x
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 48)
        label.textAlignment = .center
        return label
    }()
    
    private var yield0:CGFloat = 0
    private var yield1:CGFloat = 0
    
    private lazy var yieldTime1:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: AreaHeight / 2 + 54, width: ScreenWidth, height: 44))
        label.center.x = view.center.x
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 48)
        label.textAlignment = .center
        return label
    }()
    
    private var player0BeginTime:TimeInterval = 0
    private var player1BeginTime:TimeInterval = 0
    
    private var player0ConsumeTime:TimeInterval = 0
    private var player1ConsumeTime:TimeInterval = 0
    private var beginTime:TimeInterval = 0
    private var isBegin:Bool = false
    private var isEnd0:Bool = false
    private var isEnd1:Bool = false
    
    private lazy var cubePicker1:CubePickerView = {
        let cube = CubePickerView(frame:CGRect(x: 0, y: AreaHeight + 44, width: 320, height: 260))
        cube.stepDelegate = self
        cube.alpha = 0.0
        cube.center.x = view.center.x
        cube.center.y = player1View.center.y
        cube.tag = 1
        return cube
    }()
    
    private lazy var cubePicker0:CubePickerView = {
        let cube = CubePickerView(frame:.zero)
        cube.frame.size = CGSize(width: 320, height: 260)
        cube.stepDelegate = self
        cube.alpha = 0.0
        cube.center.x = view.center.x
        cube.center.y = player0View.center.y
        cube.tag = 0
        cube.transform = CGAffineTransform(rotationAngle: .pi)
        return cube
    }()
    
    private var isBonus:Bool = false
    
    private lazy var showRing:AVAudioPlayer = {
        //获取文件路径
        guard let path = Bundle.main.path(forResource: "show", ofType: ".MP3") else{
            print("无法获取文件路径")
            return AVAudioPlayer()
        }
        
        guard let url = URL(string: path) else{
            return AVAudioPlayer()
        }

        do{
            let player = try?AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            return player!
        }
    }()
    
    private lazy var hiddenRing:AVAudioPlayer = {
        //获取文件路径
        guard let path = Bundle.main.path(forResource: "hidden", ofType: ".MP3") else{
            print("无法获取文件路径")
            return AVAudioPlayer()
        }
        
        guard let url = URL(string: path) else{
            return AVAudioPlayer()
        }

        do{
            let player = try?AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            return player!
        }
    }()
    
    private var starView:UIImageView = {
        if #available(iOS 13.0, *){
            return UIImageView(image: UIImage(systemName: "star.fill")?.withTintColor(.yellow, renderingMode: .alwaysOriginal))
        }else{
            let image = UIImageView(image: UIImage(named: "shoucang"))
            image.frame.size = CGSize(width: 24, height: 24)
            image.contentMode = .scaleAspectFit
            return image
        }
    }()
    private var isDNF:Bool = false
    
    let cubeSource:[String] = [
                      "二阶速拧"
                      ,"三阶速拧"
                      ,"四阶速拧"
                      ,"五阶速拧"
                      ,"五魔方"
                      ,"金字塔"
                      ,"斜转"
                      ,"三阶单手"
                      ,"三阶盲拧"
                      ]
    
    private var yieldTitle:String = ""
    private var yieldContent:String = ""
    private var confirmTitle:String = ""
    private var cancelTitle:String = ""

}

//MARK: - UI
extension ViewController{
    func initView(){
        view.backgroundColor = .black
        view.addSubview(player0View)
        view.addSubview(player1View)
        view.addSubview(counterView)
        view.addSubview(player1MoreOp)
        view.addSubview(player0MoreOp)
        
        view.addSubview(cubePicker1)
        view.addSubview(cubePicker0)
        
        randomStep1.text = randomManager.randomSteps(type: .Third)
        randomStep1.sizeToFit()
        randomStep0.text = randomStep1.text
        randomStep0.sizeToFit()
        
        NotificationCenter.default.addObserver(forName: LanguageChange, object: nil, queue: .main) {[weak self] notic in
            guard let self = self else{ return }
            self.changeLanguage()
        }
        changeLanguage()
    }
    
    func start(){
        if isReady0 && isReady1{
            //震动
            let vir = SystemSoundID(kSystemSoundID_Vibrate)
            AudioServicesPlaySystemSound(vir)
            isDNF = false
            player0TimeLabel.backgroundColor = .clear
            player1TimeLabel.backgroundColor = .clear
            //计时
            if link == nil{
                link = counter
            }
            
            beginTime = Date().timeIntervalSince1970
            //开始计时
            link?.add(to: .current, forMode: .default)
            isBegin = true
            
        }
    }
    
    func ready(){
        player0TimeLabel.backgroundColor = .green
        player1TimeLabel.backgroundColor = .green
    }
    
    @objc
    func remakeGame(sender:UIButton){
        player0ScoreLabel.text = "0"
        player1ScoreLabel.text = "0"
        score0 = 0
        score1 = 0
        player0BeginTime = 0
        player1BeginTime = 0
        player0ConsumeTime = 0
        player1ConsumeTime = 0
        player1TimeLabel.text = "0.000"
        player0TimeLabel.text = "0.000"
        yieldTime0.text = ""
        yieldTime1.text = ""
        yield1 = 0
        yield0 = 0
        hidenmore(sender: sender)
    }
    
    func canTouch(){
        if player1MoreOp.isHidden && player0MoreOp.isHidden{
            player0TimeLabel.isUserInteractionEnabled = true
            player1TimeLabel.isUserInteractionEnabled = true
        }
    }
    
    @objc
    func hidenmore(sender:UIButton){
        if sender.tag == 0{
            player0MoreOp.isHidden = true
        }else{
            player1MoreOp.isHidden = true
        }
        
        canTouch()
    }
        
    //比较两个选手用时
    func judge(){
        if isEnd0 && isEnd1{
            if link != nil{
                //移除计时器
                link?.invalidate()
                link = nil
            }
            
            let srscore0 = player0TimeLabel.text!
            let srscore1 = player1TimeLabel.text!
            
           
            //相同情况下
            if srscore0 == srscore1{
                if yield0 == yield1{
                    score1 += 1
                    player1ScoreLabel.text = score1.description
                    score0 += 1
                    player0ScoreLabel.text = score0.description
                }else if yield1 < yield0{
                    score1 += 1
                    player1ScoreLabel.text = score1.description
                }else{
                    score0 += 1
                    player0ScoreLabel.text = score0.description
                }
               
            }else{
                if isBonus{
                    player1ConsumeTime -= yield1
                    player0ConsumeTime -= yield0
                }
                if player0ConsumeTime + yield0 > player1ConsumeTime + yield1{
                    score1 += 1
                    player1ScoreLabel.text = score1.description
                }else{
                    score0 += 1
                    player0ScoreLabel.text = score0.description
                }
            }
        
            isBegin = false
            isEnd0 = false
            isEnd1 = false
            isPlaying1 = false
            isPlaying0 = false
            isReady0 = false
            isReady1 = false
            let player0 = randomManager.type(name: cubeSource[player0Selected])
            let player1 = randomManager.type(name: cubeSource[player1Selected])
            if player0Selected == player1Selected{
                randomStep0.text = randomManager.randomSteps(type:player0)
                randomStep1.text = randomStep0.text
            }else{
                randomStep0.text = randomManager.randomSteps(type:player0)
                randomStep1.text = randomManager.randomSteps(type: player1)
            }
            randomStep1.sizeToFit()
            randomStep0.sizeToFit()
            randomStep0.frame.size.width = ScreenWidth
            randomStep1.frame.size.width = ScreenWidth
        }
        
    }
    
    func isHiddenCubeTable(_ tag:Int,isHidden:Bool){
        if tag == 0{
            cubePicker0.isHidden = isHidden
        }else{
            cubePicker1.isHidden = isHidden
        }
    }
        
    @objc
    func isHiddenCubeTable(sender:UIButton){
        if sender.tag == 0 {
            cubePicker0.isHidden = false
            player0MoreOp.isHidden = true
            cubePicker0.alpha = 1.0
        }else{
            cubePicker1.isHidden = false
            player1MoreOp.isHidden = true
            cubePicker1.alpha = 1.0
        }
        
    }
    
}

extension ViewController{
    @objc
    func counter(sender:CADisplayLink){
        let now = Date().timeIntervalSince1970
        let temp = now - beginTime
        let format = String(format: "%.3f", temp)
        let diff = abs(yield1 - yield0)
        let dis = temp < diff ?0.000:temp - diff
        if !isEnd0{
            player0TimeLabel.text = format
            if temp > 60{
                let min = Int(temp / 60)
                let remainder = temp.truncatingRemainder(dividingBy: 60)
                let d = remainder < 10 ?"0" + String(format: "%.3f", remainder) :String(format: "%.3f", remainder)
                player0TimeLabel.text = String(format: "%d:%@",min, d)
            }
            //彩蛋
            if isBonus,yield0 > yield1{
                player0TimeLabel.text = String(format: "%.3f", dis)
                if temp > 60{
                    let min = Int(dis / 60)
                    let remainder = dis.truncatingRemainder(dividingBy: 60)
                    let d = remainder < 10 ?"0" + String(format: "%.3f", remainder) :String(format: "%.3f", remainder)
                    player0TimeLabel.text = String(format: "%d:%@",min, d)
                }
            }
        }
        if !isEnd1{
            player1TimeLabel.text = format
            if temp > 60{
                let min = Int(temp / 60)
                let remainder = temp.truncatingRemainder(dividingBy: 60)
                let d = remainder < 10 ?"0" + String(format: "%.3f", remainder) :String(format: "%.3f", remainder)
                player1TimeLabel.text = String(format: "%d:%@",min, d)
            }
            if isBonus,yield1 > yield0{
                player1TimeLabel.text = String(format: "%.3f", dis)
                if temp > 60{
                    let min = Int(dis / 60)
                    let remainder = dis.truncatingRemainder(dividingBy: 60)
                    let d = remainder < 10 ?"0" + String(format: "%.3f", remainder) :String(format: "%.3f", remainder)
                    player1TimeLabel.text = String(format: "%d:%@",min, d)
                }
            }
        }
        
    }
    

    //显示更多操作
    @objc
    func showMore1(sender:UIButton){
        if sender.tag == 0{
            player0MoreOp.isHidden = false
            player0MoreOp.alpha = 1.0
        }else{
            player1MoreOp.isHidden = false
            player1MoreOp.alpha = 1.0
        }
        player0TimeLabel.isUserInteractionEnabled = false
        player1TimeLabel.isUserInteractionEnabled = false
        
    }
    
    @objc
    func startBonus(sender:UILongPressGestureRecognizer){
        print(sender.state.rawValue)
        if sender.state == .began{
            isBonus = !isBonus
            starView.isHidden = !isBonus
            if isBonus{
                showRing.play()
            }else{
                hiddenRing.play()
            }
        }else{
            return
        }
       
    }
    
    @objc
    func fieldTime(sender:UIButton){
        hidenmore(sender: sender)
        let alert = UIAlertController(title: yieldTitle, message: yieldContent, preferredStyle: .alert)
        let ok = UIAlertAction(title: confirmTitle, style: .default) { action in
            let textfield = alert.textFields?[0]
            guard let text = textfield?.text else{
                return
            }
            if sender.tag == 0{
                self.yield0 = CGFloat((text as NSString).floatValue)
                self.yield1 = 0
                self.yieldTime1.text = ""
                self.yieldTime0.text = String(format: "+%.3fs", self.yield0)
            }else{
                self.yield1 = CGFloat((text as NSString).floatValue)
                self.yield0 = 0
                
                self.yieldTime0.text = ""
                self.yieldTime1.text = String(format: "+%.3fs", self.yield1)
            }
        }
        let cancel = UIAlertAction(title: cancelTitle, style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        alert.addTextField{ textfield in
            textfield.keyboardType = .decimalPad
        }
        
        present(alert, animated: true)
    }
    
    ///DNF
    @objc
    func DNF(sender:UIButton){
        //
        if player1ConsumeTime == 0 || player0ConsumeTime == 0{
            hidenmore(sender: sender)
            return
        }
        if sender.tag == 0{
           //本来耗时就多了就没有意义了
            if player0ConsumeTime + yield0 > player1ConsumeTime + yield1 || isDNF{
                hidenmore(sender: sender)
                return
            }
            isDNF = true
            score1 += 1
            score0 -= 1
            score0 = score0 < 0 ?0:score0
            player0ScoreLabel.text = score0.description
            player1ScoreLabel.text = score1.description
            isDNF = true
            
        }else{
            if player1ConsumeTime + yield1 > player0ConsumeTime + yield0 || isDNF{
                hidenmore(sender: sender)
                return
            }
            isDNF = true
            score0 += 1
            score1 -= 1
            score1 = score1 < 0 ?0:score1
            player0ScoreLabel.text = score0.description
            player1ScoreLabel.text = score1.description
        }
        hidenmore(sender: sender)
    }
    
    //切换语言
    @objc
    func switchLang(sender:Any){
        let lang = UserDefaults.standard.value(forKey: "language") as! String
        if lang == "zh-Hans"{
            UserDefaults.standard.set("en", forKey: "language")
        }else{
            UserDefaults.standard.set("zh-Hans", forKey: "language")
        }
        //使用通知切换语言
        NotificationCenter.default.post(name: LanguageChange, object: nil)
    }
    
    func changeLanguage(){
        let lang = UserDefaults.standard.object(forKey: "language") as! String
        var path:String
        if lang == "zh-Hans"{
            path = Bundle.main.path(forResource: "ch", ofType: "lproj")!
        }else{
            path = Bundle.main.path(forResource: "eng", ofType: "lproj")!
        }
        cancelTitle = (Bundle(path: path)?.localizedString(forKey: "取消", value: nil, table: "titles"))!
        confirmTitle = (Bundle(path: path)?.localizedString(forKey: "确定", value: nil, table: "titles"))!
        
        cubePicker1.confirmTitle = confirmTitle
        cubePicker0.confirmTitle = confirmTitle
        yieldTitle = (Bundle(path: path)?.localizedString(forKey: "输入时间", value: nil, table: "titles"))!
        yieldContent = (Bundle(path: path)?.localizedString(forKey: "单位为秒", value: nil, table: "titles"))!
        
        let swTitle = (Bundle(path: path)?.localizedString(forKey: "选择魔方", value: nil, table: "titles"))!
        switchBt0.setAttributedTitle(NSAttributedString(string: swTitle,attributes: [.font:UIFont.boldSystemFont(ofSize: 16)]), for: .normal)
        switchBt1.setAttributedTitle(NSAttributedString(string: swTitle,attributes: [.font:UIFont.boldSystemFont(ofSize: 16)]), for: .normal)
        
        let yieldTitle = (Bundle(path: path)?.localizedString(forKey: "让对方几秒", value: nil, table: "titles"))!
        yieldBt0.setAttributedTitle(NSAttributedString(string: yieldTitle,attributes: [.font:UIFont.systemFont(ofSize: 16)]), for: .normal)
        yieldBt1.setAttributedTitle(NSAttributedString(string: yieldTitle,attributes: [.font:UIFont.systemFont(ofSize: 16)]), for: .normal)
        
        let remakeTitle = (Bundle(path: path)?.localizedString(forKey: "重新开始", value: nil, table: "titles"))!
        remakeBt0.setAttributedTitle(NSAttributedString(string: remakeTitle,attributes: [.font:UIFont.systemFont(ofSize: 16)]), for: .normal)
        remakeBt1.setAttributedTitle(NSAttributedString(string: remakeTitle,attributes: [.font:UIFont.systemFont(ofSize: 16)]), for: .normal)
        
        
        let langTitle = (Bundle(path: path)?.localizedString(forKey: "切换语言", value: nil, table: "titles"))!
        switchLangBt0.setAttributedTitle(NSAttributedString(string: langTitle,attributes: [.font:UIFont.systemFont(ofSize: 16)]), for: .normal)
        switchLangBt1.setAttributedTitle(NSAttributedString(string: langTitle,attributes: [.font:UIFont.systemFont(ofSize: 16)]), for: .normal)
        
        let second = (Bundle(path: path)?.localizedString(forKey: "二阶速拧", value: nil, table: "titles"))!
        let third = (Bundle(path: path)?.localizedString(forKey: "三阶魔方", value: nil, table: "titles"))!
        let four = (Bundle(path: path)?.localizedString(forKey: "四阶速拧", value: nil, table: "titles"))!
        let fifth = (Bundle(path: path)?.localizedString(forKey: "五阶速拧", value: nil, table: "titles"))!
        let five = (Bundle(path: path)?.localizedString(forKey: "五魔方", value: nil, table: "titles"))!
        let pyramid = (Bundle(path: path)?.localizedString(forKey: "金字塔", value: nil, table: "titles"))!
        let slope = (Bundle(path: path)?.localizedString(forKey: "斜转", value: nil, table: "titles"))!
        let blind = (Bundle(path: path)?.localizedString(forKey: "三阶盲拧", value: nil, table: "titles"))!
        let single = (Bundle(path: path)?.localizedString(forKey: "三阶单手", value: nil, table: "titles"))!
        let soruces = [second,third,four,fifth,five,pyramid,slope,single,blind]
        cubePicker0.cubeSource = soruces
        cubePicker1.cubeSource = soruces
        
    }
    
    @objc
    func player0Touch(sender:UITapGestureRecognizer){
        if !isBegin{
            //开始计时 显示颜色消失
            //对面玩家没有准备的情况下
            if !isReady1{
                isReady0 = false
                sender.view?.backgroundColor = .clear
            }
            start()
        }
    }

    @objc
    func player1Touch(sender:UITapGestureRecognizer){
        if !isBegin{
            if !isReady0{
                isReady1 = false
                sender.view?.backgroundColor = .clear
            }
            start()
        }
    }
}

extension ViewController:UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if isBegin{
            let tag = gestureRecognizer.view?.tag
            if tag == 0{
                isEnd0 = true
                let date = Date().timeIntervalSince1970
                player0ConsumeTime = date - beginTime
                judge()
            }else{
                isEnd1 = true
                let date = Date().timeIntervalSince1970
                player1ConsumeTime = date - beginTime
                judge()
            }
            return true
        }
        
        let view = touch.view
        view?.backgroundColor = .red
        
        if view?.tag == 0{
            isReady0 = true
        }else{
            isReady1 = true
        }
        //两个玩家都参与的情况下移开手指便开始游戏
        if isReady0 && isReady1{
            ready()
        }
    
        return true
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ViewController:CubePickerDelegate{
    func cubePickerCancel(cubePicker: CubePickerView) {
        cubePicker.isHidden = true
    }
    
    
    func cubePickerSteps(cubePicker: CubePickerView, index: Int,isFive:Bool) {
        cubePicker.alpha = 0.0
        player0TimeLabel.isUserInteractionEnabled = true
        player1TimeLabel.isUserInteractionEnabled = true
        let type = randomManager.type(name: cubeSource[index])
        let steps = randomManager.randomSteps(type: type)
        if cubePicker.tag == 0{
            player0Selected = index
            if index == player1Selected{
                randomStep0.text = randomStep1.text
            }else{
                randomStep0.text = steps
            }
            if isFive{
                randomStep0.font = ScreenHeight < 690 ?UIFont.systemFont(ofSize: 13):UIFont.preferredFont(forTextStyle: .body)
                randomStep0.frame.origin.y = 0
                randomStep0.frame.size.height = 180
            }else{
                randomStep0.font = UIFont.systemFont(ofSize: 20)
                randomStep0.frame.origin.y = 32
                randomStep0.sizeToFit()
            }
        }else{
            player1Selected = index
            if index == player0Selected{
                randomStep1.text = randomStep0.text
            }else{
                randomStep1.text = steps
            }
            if isFive{
                randomStep1.font = ScreenHeight < 690 ?UIFont.systemFont(ofSize: 13):UIFont.preferredFont(forTextStyle: .body)
                randomStep1.frame.origin.y = 0
                randomStep1.frame.size.height = 180
            }else{
                randomStep1.font = UIFont.systemFont(ofSize: 20)
                randomStep1.frame.origin.y = 32
                randomStep1.sizeToFit()
            }
            
        }
        randomStep0.frame.size.width = ScreenWidth
        randomStep1.frame.size.width = ScreenWidth
    }
}
