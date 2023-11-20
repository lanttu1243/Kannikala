/* Sources:
 https://developer.apple.com/forums/thread/123568
 https://developer.apple.com/documentation/corebluetooth/transferring_data_between_bluetooth_low_energy_devices
 https://chat.openai.com/share/2b249ac1-d40c-4d53-89fb-f903d68f9882
 https://medium.com/@nebsp/hello-bluetooth-a-simple-swift-app-for-communicating-with-an-arduino-bbf26e089999
 https://www.youtube.com/watch?v=n-f0BwxKSD0
 https://github.com/StarryInternet/CombineCoreBluetooth
 https://www.reddit.com/r/SwiftUI/comments/za3o2i/corebluetooth_with_swiftui/
 https://www.kodeco.com/231-core-bluetooth-tutorial-for-ios-heart-rate-monitor
 
 */
import SwiftUI
import CoreBluetooth
import os

class BluetoothViewModel: NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    private var targetPeripheral: CBPeripheral? // Store the target peripheral
    private var count: Int = 0
    @Published var connectedPeripheralName: String? = "No peripheral connected" // Store the connected peripheral name
    @Published var peripheralNames: [String] = []
    @Published var receivedData: String = "No data received"
    @Published var connectedPeripheral: CBPeripheral?
    @Published var dataIn: [Int8] = [0]
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
}
extension BluetoothViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "kannikala_v0.1" { // Check for the specific name
            self.targetPeripheral = peripheral // Store the target peripheral
            self.centralManager?.stopScan() // Stop scanning once the target is found
            self.centralManager?.connect(peripheral, options: nil) // Initiate connection
        }
        if !peripheralNames.contains(peripheral.name ?? "") {
            self.peripheralNames.append(peripheral.name ?? "unnamed device")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Handle the connected peripheral here
        if let peripheralName = peripheral.name {
            self.connectedPeripheralName = "Connected to: \(peripheralName)" // Update the connectedPeripheralName
        } else {
            self.connectedPeripheralName = "Connected to peripheral with no name"
        }
        print("Connected to peripheral: \(peripheral.name ?? "Unknown")")
        self.connectedPeripheral = peripheral
        self.connectedPeripheral?.delegate = self
        
        self.connectedPeripheral?.discoverServices(nil)
            
        
    }
}
extension BluetoothViewModel: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("discovering services")
        if let services = peripheral.services {
            print("I am here")
            for service in services {
                print("I am now here")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("now discovering characteristics")
        if let characteristics = service.characteristics {
            print("found one")
            for characteristic in characteristics {
                print("analysing")
                print(characteristic)
                print(characteristic.properties)
                if characteristic.properties.contains(.notify) {
                    print("setting notify values")
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let defData = Data(capacity: 4)
        let data = characteristic.value ?? defData
        if data != defData {
            let x: Int8 = data.withUnsafeBytes({
               (rawPtr: UnsafeRawBufferPointer) in
               return rawPtr.load(as: Int8.self)
               })
            print(x)
            self.dataIn.append(x)
        }
        
    }
}

class BluetoothHandling: NSObject, ObservableObject {
    @ObservedObject private var bluetoothViewModel = BluetoothViewModel()
}
struct ContentView: View {
    @ObservedObject private var bluetoothHandling = BluetoothHandling()
    @ObservedObject private var bluetoothViewModel = BluetoothViewModel()
    @State var count: Int = 0
    var body: some View {
        VStack{
            Text("Connected Device: \(bluetoothViewModel.connectedPeripheralName!)")
            Text("Current count \(bluetoothViewModel.dataIn.last ?? -1)\n")
            HStack {
                Button(action: {
                    self.count += 1
                    print("Count increased by 1")
                    //print(bluetoothViewModel.connectedPeripheral?.services ?? "None")
                }, label: {Text("Press Me1!")})
                .padding()
                .background(Color(red: 0, green: 0.5, blue: 0.5))
                .clipShape(Capsule())
                .tint(Color(red: 1, green: 0, blue: 0))
                
                Button(action: {
                    self.count += 2
                }, label: {Text("Press Me2!")})
                .padding()
                .background(Color(red: 0, green: 0.5, blue: 0.5))
                .clipShape(Capsule())
                .tint(Color(red: 1, green: 0, blue: 0))
            };
            HStack{
                Button(action: {
                    self.count += 3
                }, label: {Text("Press Me3!")})
                .padding()
                .background(Color(red: 0, green: 0.5, blue: 0.5))
                .clipShape(Capsule())
                .tint(Color(red: 1, green: 0, blue: 0))
                
                Button(action: {
                    self.count += 4
                }, label: {Text("Press Me4!")})
                .padding()
                .background(Color(red: 0, green: 0.5, blue: 0.5))
                .clipShape(Capsule())
                .tint(Color(red: 1, green: 0, blue: 0))
            }
        }
    }
}
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    return true
}

#Preview {
 ContentView()
}

