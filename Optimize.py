ProgramName="Optimize By Zack Ver260305"
import sys
import socket
import datetime
import subprocess
subprocess.run(['Program\Optimize.bat',"ProgramName",ProgramName])
#====================================================================================
OptionsList={}
def Are_you_sure():
    OptionsList["Are_you_sure"]=input("\n\n"+OptionsList["Options"]+" Are you sure? (輸入Y/N繼續):").upper()
    if OptionsList["Are_you_sure"]!="Y":
        menu()
def exit_program():
    sys.exit()
def RunBatch():
    Are_you_sure()
    subprocess.run(['Program\Optimize.bat',OptionsList["Options"]])
#====================================================================================
def menu():
    menu_OptionsList={
        "1":("RE-Install_Optimize",Instell),
        "2":("mpv_PlayKit_Update",RunBatch),
        "3":("mpv_PlayKit_Backup",RunBatch),
        "4":("DATABackup",RunBatch),
        "5":("Zack_DATABackup",RunBatch),
        "6":("Exit", exit_program)
    }
    while True:
        subprocess.run('cls', shell=True)
        print(ProgramName+"\n\n")
        for key, value in menu_OptionsList.items():
            print(f"{key}.{value[0]}")
        choice=input("\n請輸入選項: [1,2,3,4,5,6]:")
        if choice in menu_OptionsList:
            OptionsList["Options"]=menu_OptionsList[choice][0]
            menu_OptionsList[choice][1]()
#====================================================================================
def Instell():
    subprocess.run('cls', shell=True)
    print(ProgramName+"\n\n")
    while True:
        OptionsList["PCName"]=input("請輸入電腦名稱:")
        if OptionsList["PCName"]!="":
            break
        else:
            OptionsList["PCName"]=socket.gethostname()
            if OptionsList["PCName"]!="":
                break
    InstellList=[
        "Zack_Install_Mode",
        "CrackActivation",
        "DATARestore",
        "AnyDeskRestore"
    ]
    for Questions in InstellList:
        OptionsList[Questions]=input(Questions+"? (輸入Y/N繼續):").upper()
        if OptionsList[Questions]=="Y":
            if Questions=="Zack_Install_Mode":
                OptionsList[Questions]=input("自家用? (輸入Y/N繼續):").upper()
                if OptionsList[Questions]=="Y":
                    OptionsList[Questions]="Zack_Install"
                else:
                    OptionsList[Questions]="Zack_Normal_Install"
            else:
                OptionsList[Questions]=Questions
        else:
            if Questions=="Zack_Install_Mode":
                OptionsList[Questions]="Normal_Install"
            else:   
                OptionsList[Questions]="Do not "+Questions
    result=subprocess.run('cscript //nologo "%windir%\system32\slmgr.vbs" /dli | find "已取得授權"', stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, shell=True)
    if "已取得授權" in result.stdout:
        WindowsLicense="Windows已啟用"
    else:
        WindowsLicense="Windows未啟用"
    subprocess.run('cls', shell=True)
    print(ProgramName)
    print(WindowsLicense)
    print("\n")
    print("電腦名稱:"+OptionsList["PCName"])
    for Questions in InstellList:
        print(OptionsList[Questions])
    Are_you_sure()
    YYMMDD = datetime.datetime.now().strftime("%y%m%d")
    subprocess.run('REG add HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\OEMInformation /v Model /t REG_SZ /f /d "Zack Optimize Ver' + YYMMDD)
    subprocess.run(['Program\Optimize.bat',OptionsList["Options"],OptionsList["Zack_Install_Mode"],OptionsList["CrackActivation"],OptionsList["DATARestore"],OptionsList["AnyDeskRestore"],OptionsList["PCName"],WindowsLicense])
#====================================================================================
if __name__ == "__main__":
    menu()
#====================================================================================