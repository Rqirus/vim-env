from cryptography.fernet import Fernet
import socket
import subprocess
import threading
import signal
import sys

# 生成密钥，实际应用中应该安全地共享和存储这个密钥

# 从文件中读取密钥
with open('secret.key', 'rb') as key_file:
    key = key_file.read()
cipher_suite = Fernet(key)

# 服务端配置
HOST = '10.5.81.211'
PORT = 65432

def signal_handler(signal, frame):
    print('接收到中断信号，程序退出')
    sys.exit(0)
        # 注册中断信号处理函数

def handle_client(conn, addr):
    print(f"新连接：{addr}")
    try:
        while True:
            encrypted_data = conn.recv(1024)
            if not encrypted_data:
                break
            try:
                # 解密数据
                data = cipher_suite.decrypt(encrypted_data)
                command = data.decode('utf-8')
                # 执行命令
                subprocess.Popen(command, shell=True)
                conn.sendall(cipher_suite.encrypt(b'Command executed.'))
            except Exception as e:
                conn.sendall(cipher_suite.encrypt(f'Error executing command: {e}'.encode('utf-8')))
                break
    except socket.error as e:
        print(f"Socket error: {e}")
    finally:
        conn.close()
        print(f"连接 {addr} 已关闭")

def start_server():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind((HOST, PORT))
        s.listen()
        print(f"{HOST}:{PORT}服务端启动，等待连接...")
        while True:
            print("accepting")
            try:
                conn, addr = s.accept()
                print("accepted")
                # 使用线程来处理每个新连接
                client_thread = threading.Thread(target=handle_client, args=(conn, addr))
                client_thread.start()
                print(f"活动连接数：{threading.activeCount() - 1}")
            except KeyboardInterrupt:
                print('接收到中断信号，程序退出')
                sys.exit(0)

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal_handler)
    start_server()

