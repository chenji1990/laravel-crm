import os
from subprocess import Popen, PIPE, STDOUT


def runCommands(commands: list[str]):
    for cmd in commands:
        print("--------------------------------------")
        print(f"{cmd}\n")
        p = Popen(cmd, stdout=PIPE, stderr=STDOUT, shell=True)
        text = p.stdout.readline()
        while text != b"":
            try:
                if len(temp := text.decode().strip()) > 0:
                    print(temp)
                    if temp.__contains__("ERROR"):
                        print("***** ERROR *****")
                        return
            except:
                pass
            text = p.stdout.readline()
            
def buildCRM(service: str, version: str, isPush: bool):
    dockerfile_path = os.path.join("Dockerfile")
    
    image = f"registry.cn-shanghai.aliyuncs.com/berry-med/{service}:{version}"

    cmds = []
    cmds.append(f'docker buildx build --platform linux/amd64 -f {dockerfile_path} -t {image} .')
    if isPush:
        cmds.append(f'docker push {image}')
    
    runCommands(cmds)

            
def run(version: str, isPush: bool):
  
    buildCRM("crm", version, isPush)
        

if __name__ == "__main__":
    
    isPush = False
    # isPush = True
    
    run(version="latest", isPush=isPush)
    
    runCommands([
        'docker compose -f "docker-compose.yaml" down',
        'docker compose -f "docker-compose.yaml" up',
    ])