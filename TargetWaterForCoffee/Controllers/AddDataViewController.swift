//
//  AddDataViewController.swift
//  WaterForCoffee_Store
//
//  Created by 김현준 on 2022/08/05.
//

import UIKit
import CoreData

protocol CafeDetailTableReloadDelegate: AnyObject {
    func reloadTable()
}

class AddDataViewController: UIViewController {
    
    let titleLabel = UILabel()
    let tableView = UITableView()
    let memoLabel = UILabel()
    let memoTextView = UITextView()
    let saveButton = UIButton(type: .system)
    let dataTypes = ["Total Hardness", "Alkalinity", "PH", "Filter"]
    var InsertData = ["", "", "", "", "", ""]
    
    weak var delegate: CafeDetailTableReloadDelegate?
    
    let coreDataManager = CoreDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
    }
}

// [ MARK ] Set UI
extension AddDataViewController {
    private func setUI(){
        view.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.97, alpha: 1)
        navigationController?.isNavigationBarHidden = true
        
        [titleLabel, tableView, memoLabel, memoTextView, saveButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 15),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor , constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            tableView.heightAnchor.constraint(equalToConstant: 202),
            
            memoLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            memoLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            memoLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 20),
            memoLabel.heightAnchor.constraint(equalToConstant: 30),
            
            memoTextView.topAnchor.constraint(equalTo: memoLabel.bottomAnchor, constant: 5),
            memoTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            memoTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            memoTextView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -20),
            
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(view.frame.height / 4) * 1.13),
            saveButton.heightAnchor.constraint(equalToConstant: 49)
        ])
        // Title View
        titleLabel.text = "데이터 입력"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.sizeToFit()
        
        // Table View
        tableView.register(AddDataTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .singleLine
        tableView.layer.cornerRadius = 10
        tableView.separatorInset.left = 20
        tableView.separatorInset.right = 20
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        // Memo Label
        memoLabel.text = "Memo"
        memoLabel.textColor = .darkGray
        memoLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        
        // Memo TextView
        memoTextView.backgroundColor = .white
        memoTextView.layer.cornerRadius = 10
        memoTextView.font = UIFont.systemFont(ofSize: 14)
        memoTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        memoTextView.keyboardType = .default
        
        // Save Button
        saveButton.setTitle("저장하기", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        saveButton.addTarget(self, action: #selector(didTapSaveButton(_:)), for: .touchUpInside)
        saveButton.layer.cornerRadius = 10
        saveButton.isEnabled = false
        saveButton.backgroundColor = .lightGray
    }
}

// [ MARK ] Function
extension AddDataViewController {
    @objc // Save Button
    func didTapSaveButton(_ sender: UIButton) {
        if Int(InsertData[0])! >= 200 || Int(InsertData[1])! >= 120 || Int(InsertData[2])! >= 10 {
            let message = "입력한 데이터의 크기가 적절하지 않습니다."
            let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "확인", style: .default){ _ in
                self.navigationItem.title = "데이터 입력하기"
                self.view.frame.origin.y = 0
                self.view.endEditing(true)
            }
            alertController.addAction(confirmAction)
            self.present(alertController, animated: true)
        } else {
            // set empty Data
            if InsertData[3] == ""{
                InsertData[3] = "No Filter"
            }
            InsertData[4] = memoTextView.text ?? ""
            if InsertData[4] == "" {
                InsertData[4] = "No Memo"
            }
            InsertData[5] = circles(hardness: Int(InsertData[0])!, alkalinity: Int(InsertData[1])!)
            
            // CoreData
            coreDataManager.saveCafeDetailData(hardness: InsertData[0], alkalinity: InsertData[1], ph: InsertData[2], circle: InsertData[5], filter: InsertData[3], memo: InsertData[4]) {
                self.view.frame.origin.y = 0
                self.view.endEditing(true)
                let resultMessage = "데이터 리포트가 저장되었습니다."
                let resultAlertController = UIAlertController(title: "", message: resultMessage, preferredStyle: .alert)
                let resultConfirmAction = UIAlertAction(title: "확인", style: .default){ _ in
                    self.dismiss(animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.delegate?.reloadTable()
                        let dataView = UIApplication.topViewController()!
                        dataView.dismiss(animated: true)
                    }
                }
                resultAlertController.addAction(resultConfirmAction)
                self.present(resultAlertController, animated: true)
            }
        }
    }
}

// [ MARK ] Keyboard Set
extension AddDataViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.frame.origin.y = 0
        self.view.endEditing(true)
    }
    @objc func keyboardWillShow(_ sender:Notification) {
        self.view.frame.origin.y = 0
        self.view.frame.origin.y = -60
    }
}

// [ MARK ] Table View Data Source
extension AddDataViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? AddDataTableViewCell else {fatalError()}
        
        // Row 데이터 타입 삽입
        cell.dataTypeLabel.text = dataTypes[indexPath.row]
        // 데이터 타입이 필터일 경우 텍스트 입력 키보드 활성화
        if cell.dataTypeLabel.text == "Filter"{
            cell.textView.keyboardType = .asciiCapable
        }
        // 셀 선택 이벤트 제거
        cell.selectionStyle = .none
        cell.delegate = self
        cell.tag = indexPath.row
        return cell
    }
}

// [MARK] Protocol Function Setting
extension AddDataViewController: AddDataTableViewCellDelegate {
    func setData(data: String, tag: Int){
        InsertData[tag] = data
        if InsertData[0] != "", InsertData[1] != "", InsertData[2] != "" {
            saveButton.isEnabled = true
            saveButton.backgroundColor = .systemBlue
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = .lightGray
        }
    }
}

