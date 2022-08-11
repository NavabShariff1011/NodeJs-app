pipeline {
    agent none
    parameters {
        
       
        string(name: 'APPREPO' , defaultValue: 'nodejs' , description: 'please give your app image repo')
        string(name: 'ECRURL' , defaultValue: '020567785666.dkr.ecr.ap-south-1.amazonaws.com' , description: 'please give your repo url for storing image')    
        string(name: 'REGION' , defaultValue: 'ap-south-1' , description: 'region')
        password(name: 'PASSWD' , defaultValue: '' , description: 'git hub passwd')
    }
    stages {
        stage('checkout') {
            agent { label 'build' }
            steps {
               git branch: 'dev', credentialsId: 'GitHubCred', url: 'https://github.com/navabshariff1011/NodeJs-app.git' 
            }
        }
        stage('validating commit') {
            agent { label 'build' }
            
            steps {
                script {
                    env.BUILDME = "yes" 
                }
                
                }
        }
        stage('Build Artifact') {
      
                
            agent { label 'build' }
        when {environment name: 'BUILDME' , value: 'yes'}
            steps {
               script {
                  No = env.BUILD_ID
               
               
              sh 'npm install'
              
              sh 'tar czf nodejs${NO}.tgz node_modules src/app.js package.json'
              
             
              
            }
          }
        }
        
    
        stage('SonarQube Analysis') {
                 agent { label 'build' }
                 when {environment name: 'BUILDME' , value: 'yes' }
                 steps {
                    withSonarQubeEnv('SonarQube') {
                             
                               sh "npm run sonar"
                           
                    }
                 }
        }
                                                           
        stage('Quality Gate'){
          agent { label 'build' }
          when {environment name: 'BUILDME' , value: 'yes'}
          steps {
              script {
                  timeout(time: 2, unit: 'MINUTES') {
                  def qg = waitForQualityGate()
                  if (qg.status != 'OK') {
                      error "Pipeline aborted due jai balayya to quality gate failure: ${qg.status}"
                  }
                  }
              }
                
          }
          
        }
        

        stage('Jfrog Artifactory') {
            agent { label 'build' }
            
            steps {
                script {
                    /* Define The Artifactory Server Details */
                  
                    No = env.BUILD_ID
                    def server = Artifactory.server 'JFROG'
                    def artifacts = """{
                        "files": [{
                        "pattern": "nodejs${No}.tgz" ,
                        "target": "final/"
                        }]
                    }"""
                    /* Upload the files to artifactory repo */
                    server.upload(artifacts)
                }
            }
             
        }
        
        stage('Build Image') {
            agent { label 'build' }
            steps {
                script {
                    appTag = params.APPREPO + ":" + env.BUILD_ID
                    
                    ECR = "https://" + params.ECRURL
                                
                    docker.withRegistry( ECR, 'ecr:ap-south-1:AWSCRED') {

                 myImage = docker.build(appTag)
                 
                 myImage.push()
                    
                }
            }
          }
       }
       
       stage('scanning Image') {
           agent { label 'build' }
           steps {
               withAWS(credentials: 'AWSCRED') {
                   sh "chmod +x getimagescan.sh; ./getimagescan.sh ${params.APPREPO} ${env.BUILD_ID} ${params.REGION}"
               }
           }
       }
       stage('smoke dploy') {
            agent { label 'build' }
            when{environment name: 'BUILDME' , value: 'yes'}
            steps {
                script {
                    env.IMAGE = params.APPREPO + ":" + env.BUILD_ID

                    sh ("export deployimage=${IMAGE}; docker-compose up -d")
                }
            }
        }
        
        stage('smoke test') {
            agent { label 'build' }
            when {environment name: 'BUILDME' , value: 'yes'}
            steps {
                catchError(buildResult: 'SUCCESS' , message: 'TEST-CASES FAILED' , stageResult: 'SUCCESS')
                {
                    sh "sleep 10; chmod +x runsmoke.sh; ./runsmoke.sh"
                }
                }
                post {
                    always {
                        script {
                            env.IMAGE = params.APPREPO + ":" + env.BUILD_ID
                            
                            sh ("export deployimage=${IMAGE}; docker-compose down")
                            
                            sh ("docker rmi ${params.APPREPO}:${env.BUILD_ID}")
                        }
                    }
                }
        }
        stage('Deploy') {
  
               agent { label 'build' }
               steps { 
        git branch: 'dev', credentialsId: 'GitHubCred', url: 'https://github.com/navabshariff1011/kubernetes.git'
	 	dir ("./k8smanifest") {
	      sh "sed -i 's/image:.*/image: $ECRURL$IMAGE/g' deployment.yml" // make sure the ECRURL has \/ at the end
	    }
		sh 'git commit -a -m "New deployment for Build $IMAGE"'
		sh "git push https://navabshariff1011:$PASSWD@github.com/navabshariff1011/kubernetes.git"
    }
  }
        
    }//stages
}

   
        


        
     
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
       
    

