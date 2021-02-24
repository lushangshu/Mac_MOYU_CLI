//
//  main.swift
//  moyu
//
//  Created by lu.ss on 2021/2/10.
//

import Foundation
import Dispatch
import Alamofire //https://github.com/Alamofire/Alamofire
import SwiftCLI //https://github.com/jakeheis/SwiftCLI#parameters
import Alamofire_Synchronous //https://github.com/Dalodd/Alamofire-Synchronous   Synchronous requests for Alamofire
import SwiftSoup //https://github.com/scinfu/SwiftSoup

class moyuCommand: Command {
   let name = "moyu"
    
    @Flag("-q", "--qiushibaike", description: "糗事百科")
    var qiushibaike:Bool
    
    @Flag("-p", "--PremierLeague", description: "Premier league table")
    var premierLeague: Bool
    
    @Flag("-c", "--ChampionLeague", description: "Champion league table")
    var championLeague:Bool
    
    @Flag("-l","--LaLiga",description:"La Liga")
    var laliga:Bool
    
    @Flag("-f","--FrenchLeague",description:"French League")
    var french:Bool
    
    @Flag("-s","--SeriaA",description:"Seria A")
    var seria:Bool
    
    @Flag("-b","--Bundsliga",description:"Seria A")
    var bund:Bool
    
    @Flag("-w","--weibo",description:"Weibo Hot Searches")
    var weibo:Bool
    
    @Flag("-i","--ifanr",description:"iFanr Daily News")
    var ifanr:Bool
    
    @Flag("-z","--Zhihu",description:"Zhihu Tucao")
    var zhihu:Bool
    
    @Flag("-t","--Translate",description:"Translate")
    var translate:Bool
    
    
    
    @Param var moyuType:String?

    func execute() throws {
        print("开心快乐 每天摸鱼")
        if  premierLeague {
            print("Premier League table")
            let url = "https://m.hupu.com/soccer/epl/tables"
            footballTableRequest(url: url)
        }else if championLeague{
            print("欧冠积分")
            let url = "https://m.hupu.com/soccer/ucl/tables"
            championLeagueRequest()
        }else if laliga{
            print("西甲积分")
            let url = "https://m.hupu.com/soccer/laliga/tables"
            footballTableRequest(url: url)
        }else if bund{
            print("德甲积分")
            let url = "https://m.hupu.com/soccer/1bund/tables"
            footballTableRequest(url: url)
        }else if french{
            print("法甲积分")
            let url = "https://m.hupu.com/soccer/ligue1/tables"
            footballTableRequest(url: url)
        }else if seria{
            print("意甲积分")
            let url = "https://m.hupu.com/soccer/seriea/tables"
            footballTableRequest(url: url)
        }else if ifanr{
            print("go ifanr")
            ifanDailyNews()
        }else if zhihu{
            zhihuXiache()
        }else if weibo{
            weiboHotSearch()
        }else if translate{
            translateFromEnToCN(word: moyuType ?? "")
        }

        else{
            if let moyuT = moyuType {
                QsbkRequest(page: moyuT)
            }else{
                QsbkRequest(page: "")
            }
        }
    }
}

func isChinese(str: String) -> Bool{
        let match: String = "(^[\\u4e00-\\u9fa5]+$)"
        let predicate = NSPredicate(format: "SELF matches %@", match)
        return predicate.evaluate(with: str)
}

func translateFromEnToCN(word:String){
    
    struct detail : Codable{
        let trans:String
        let orig:String
    }
    struct translateInfo : Codable {
        let sentences:Array<detail>
        let src:String
    }
    var url = ""
    if(!isChinese(str: word)){
        url = "http://translate.google.cn/translate_a/single?client=gtx&dt=t&dj=1&ie=UTF-8&sl=auto&tl=zh_CN"
    }else{
        url = "http://translate.google.cn/translate_a/single?client=gtx&dt=t&dj=1&ie=UTF-8&sl=auto&tl=EN"
    }
    let response = Alamofire.request(url,method: .get,parameters: ["q":word]).response()
    let jsonResult = String(data:response.data!,encoding: .utf8)!
    let jsonData:Data = jsonResult.data(using: .utf8)!
    let decoder = JSONDecoder()
    let jsonInfo = try! decoder.decode(translateInfo.self, from:  jsonData)
    print(jsonInfo.sentences.first!.trans)
    
}

//微博热搜
func weiboHotSearch(){
    let url = "https://s.weibo.com/top/summary"
    let response = Alamofire.request(url).response()
    do{
        let html = String(data:response.data!,encoding: .utf8)!
        let doc:Document = try SwiftSoup.parse(html)
        let tdEle:Elements = try doc.select("td.td-02")

        for ele:Element in tdEle.array() {
            let linkText :String = try ele.select("a").text()
            let linkHref :String = try ele.select("a").attr("href")
           print("\(linkText) : https://s.weibo.com\(linkHref)")
        }
        }catch Exception.Error(let type,let message){
            print(message)
        }catch{
            print("error")
        }
}


//知乎日报
func zhihuXiache(){
    
    struct questionStruct{
        var title:String
        var content:String
    }
    
    let url = "https://daily.zhihu.com/"
    let response = Alamofire.request(url).response()
    do{
        let html = String(data:response.data!,encoding: .utf8)!
        let doc:Document = try SwiftSoup.parse(html)
        let contentElements:Element = try doc.select("div.main-content-wrap").first()!
        let wraps :Elements = try contentElements.select("div.wrap")
        var xcArray : Array = [String]()
        
        for wrap:Element in wraps.array() {
            let href:String = try wrap.select("a.link-button").attr("href")
            let title:String = try wrap.select("span.title").text()
           
            if(title.contains("瞎扯")){
               // print("\(href) : \(title)")
                xcArray.append("https://daily.zhihu.com"+href)
            }
        }
        
        var xcContents:Array = [questionStruct]()
        for urlPath in xcArray {
            let xcResponse = Alamofire.request(urlPath).response()
            do{
                let xcHtml = String(data:xcResponse.data!,encoding: .utf8)!
                let doc:Document = try SwiftSoup.parse(xcHtml)
                let questions :Elements = try doc.select("div.question")
                for question:Element in questions.array(){
                    let qTitle:String = try question.select("h2").first()?.text() as! String
                    let qContent:String = try question.select("p").text()
                    let quesS = questionStruct(title: qTitle, content: qContent)
                    xcContents.append(quesS)
                    
                }
            }catch{
                print("error")
            }
        }
        for quesS:questionStruct in xcContents{
            print("\n Q: \(quesS.title) \n A:\(quesS.content) ")
        }
        
    }catch Exception.Error(let type,let message){
            print(message)
    }catch{
            print("error")
    }
}

//每日早报
func ifanDailyNews(){
    let url = "https://www.ifanr.com/category/ifanrnews"
    let response = Alamofire.request(url).response()
    do{
        let html = String(data:response.data!,encoding: .utf8)!
        let doc:Document = try SwiftSoup.parse(html)
        let contentElements:Element? = try doc.select("div.article-info").first()
        let courterHrefs:Element = try contentElements!.select("a").first()!
        let href:String = try courterHrefs.attr("href")
        let nResponse = Alamofire.request(href).response()
        let nHtml = String(data:nResponse.data!,encoding: .utf8)!
        let nDoc:Document = try SwiftSoup.parse(nHtml)
        let newsElement:Element = try nDoc.select("article.o-single-content__body__content").first()!
        let newsChildren:Elements = try newsElement.children()
        for elem:Element in newsChildren.array(){
            let tagname:String = try elem.tagName()
            let eleString:String = try elem.text()
            let nEleString:String = eleString.trimmingCharacters(in: .whitespaces)
            if(tagname == "h4"){
                print("\n ==> : \(nEleString) \n")
            }else if( tagname == "p" &&  nEleString != ""){
                print(" \(nEleString) ")
            }
        }
    }catch Exception.Error(let type,let message){
            print(message)
    }catch{
            print("error")
    }
}


func QsbkRequest(page:String){
    let url = "https://www.qiushibaike.com/text/page/"+page
    let response = Alamofire.request(url).response()
    do{
        let html = String(data:response.data!,encoding: .utf8)!
        let doc:Document = try SwiftSoup.parse(html)
        let link:String = try doc.body()!.text()
        let contentElements:Element? = try doc.select("div.col1").first()
        let courterHrefs:Elements = try contentElements!.select("a.contentHerf")
        
        for ele:Element in courterHrefs.array() {
            let linkText :String = try ele.text()
            print(" \(linkText) \n -- Element.prepend(_ first: String) and Element.append(_ last: String) add text nodes to the start or end of an element's inner HTML, respectively The text should be supplied unencoded: characters like <, > etc will be treated as literals, not HTML. \n")
        }
        }catch Exception.Error(let type,let message){
            print(message)
        }catch{
            print("error")
        }
    
}

func championLeagueRequest(){
    let url = "https://m.hupu.com/soccer/ucl/tables"
    let response = Alamofire.request(url).response()
    do{
        let html = String(data:response.data!,encoding: .utf8)!
        let doc:Document = try SwiftSoup.parse(html)
        let groupTables:Elements = try doc.select("table.mod-table")
        
        for ele:Element in groupTables.array() {
            let linkText :String = try ele.text()
            let trS : Elements = try ele.select("tr.link")
            print("球队|场次|胜|平|负|进/失|积分\n")
            for tr:Element in trS.array(){
                let trText :String = try tr.text()
                print("\(trText)\n")
            }
         
        
        }
        }catch Exception.Error(let type,let message){
            print(message)
        }catch{
            print("error")
        }
}

func footballTableRequest(url:String){
   
    let response = Alamofire.request(url).response()
    print("-------------- 积分榜 -------------- \n 序号|名称|积分|场次|胜平负|进球|失球|净胜球|场均进球|场均失球|场均净胜|场均积分|")
    do{
        let html = String(data:response.data!,encoding: .utf8)!
        let doc:Document = try SwiftSoup.parse(html)
        //let link:String = try doc.body()!.text()
        let contentElements:Elements = try doc.select("table.table")
        var teamArray:Array = [String]()
        
        var loop:Int = 0
        
        for item:Element in contentElements.array() {
            let tbody:Element = try item.select("tbody").first()!
            let trElements:Elements = try tbody.select("tr")
            var res:Int = 0
            for trItem in trElements.array() {
               
                let trText :String = try trItem.text()
                if(loop == 0 ){
                    teamArray.append(trText+" ")
                }else if(loop == 1){
                    teamArray[res].append(trText)
                }
                res += 1
            }
            loop += 1
        }
        for item in teamArray {
            print(item)
        }
      
        }catch Exception.Error(let type,let message){
            print(message)
        }catch{
            print("error")
        }
}

let moyu = CLI(name: "moyu")
moyu.commands = [moyuCommand()]
moyu.go()


