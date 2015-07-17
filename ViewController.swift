//
//  ViewController.swift
//  PolyLine
//
//  Created by takashi on 2015/06/17.
//  Copyright (c) 2015年 takashi Otaki. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    let consumerKey = "YOURCONSUMERKEY"
    
    var hibiyaLine: NSDictionary = [:]
    var hibiyaLineArray = NSArray()
    
    var myMapView: MKMapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 経度緯度を設定.
        let myLan: CLLocationDegrees = 35.7155
        let myLon: CLLocationDegrees = 139.7740
        
        // 地図の中心の座標.
        var center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLan, myLon)
        
        // mapViewを生成.
        myMapView.frame = self.view.frame
        myMapView.center = self.view.center
        myMapView.centerCoordinate = center
        myMapView.delegate = self
        
        // 縮尺を指定.
        let mySpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let myRegion: MKCoordinateRegion = MKCoordinateRegion(center: center, span: mySpan)
        
        // regionをmapViewに追加.
        myMapView.region = myRegion
        
        // viewにmapViewを追加.
        self.view.addSubview(myMapView)
        
        //geoJSON取得(日比谷から)
        getGeoJson("urn:ucode:_00001C000000000000010000030C46AE")
       
        
    }
    
    
    
    //geoJSON取得
    func getGeoJson(ucode:String) {
        
        var URL = NSURL(string: "https://api.tokyometroapp.jp/api/v2/places/\(ucode).geojson?acl:consumerKey=\(consumerKey)")
        var req = NSURLRequest(URL: URL!)
        
        // NSURLConnectionを使ってAPIを取得する(非同期)
        NSURLConnection.sendAsynchronousRequest(req,
            queue: NSOperationQueue.mainQueue(),
            completionHandler: responseGeoJson)
        
    }
    
    
    //★★★★★★★★★★★★★★★★★★
    // 取得したAPIデータの処理
    func responseGeoJson(res: NSURLResponse!, data: NSData!, error: NSError!){
        
        if (error == nil) && (data != nil){
            var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSDictionary
            
           
            hibiyaLine = json as! NSDictionary
            hibiyaLineArray = hibiyaLine["coordinates"] as! NSArray
            
            CLLocationArray()

        } else {
            
            println("jsonエラー")

        }
        
    }
    
   
    
    
    func CLLocationArray() {
        
        var coordinatesHibiya:[CLLocationCoordinate2D] = []
        
        for var index = 0; index < hibiyaLineArray[0].count; ++index {
            
            var coordinate = CLLocationCoordinate2D(latitude: hibiyaLineArray[0][index][1] as! CLLocationDegrees, longitude: hibiyaLineArray[0][index][0] as! CLLocationDegrees)
            
            coordinatesHibiya.append(coordinate)
    
        }
        
        // polyline作成.
        let hibiyaPolyLine: MKPolyline = MKPolyline(coordinates: &coordinatesHibiya, count: coordinatesHibiya.count)
        
        // mapViewに線を描画.
        myMapView.addOverlay(hibiyaPolyLine)
        
        
    }
    
    
    /*
    addOverlayした際に呼ばれるデリゲートメソッド.
    */
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        // rendererを生成.
        let myPolyLineRendere: MKPolylineRenderer = MKPolylineRenderer(overlay: overlay)
        
        // 線の太さを指定.
        myPolyLineRendere.lineWidth = 5
        
        // 線の色を指定.
        myPolyLineRendere.strokeColor = UIColor(red: (168/255.0), green: (158/255.0), blue: (147/255.0), alpha: 1.0)
        
        return myPolyLineRendere
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

