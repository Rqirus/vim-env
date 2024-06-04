from cryptography.fernet import Fernet
import socket
import sys

# 密钥，应与服务端相同

# 从文件中读取密钥
with open('/home/secret.key', 'rb') as key_file:
    key = key_file.read()
cipher_suite = Fernet(key)

# 客户端配置
HOST = '10.5.81.211'
PORT = 65432
if len(sys.argv) < 2:
    print("command required.")
    exit(0)

# 获取整个命令行参数字符串
command = ' '.join(['"{}"'.format(arg) for arg in sys.argv[1:]])

#print(command)

#exit(0)
# 创建 socket 对象
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    if command.lower() == 'exit':
        exit(0)
    # 加密命令
    encrypted_command = cipher_suite.encrypt(command.encode('utf-8'))
    s.sendall(encrypted_command)
    encrypted_data = s.recv(1024)
    # 解密响应
    data = cipher_suite.decrypt(encrypted_data)
    print('服务端响应:', data.decode('utf-8'))

