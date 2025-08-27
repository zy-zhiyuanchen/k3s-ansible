pipeline {
    agent any

    parameters {
        choice(
            name: 'PLAYBOOK_ACTION',
            choices: [
                'install-all',
                'k3s-upgrade',
                'reboot', 
                'reset',
                'install-only-k3s',
                'k3s-upgrade'
            ],
            description: 'Select the action to perform'
        )

        string(
            name: 'GITHUB_REPO',
            defaultValue: 'https://github.com/zy-zhiyuanchen/k3s-ansible.git',
            description: 'K3s Ansible GitHub Repository URL'
        )

        string(
            name: 'GITHUB_BRANCH',
            defaultValue: 'main',
            description: 'Git branch to checkout'
        )

        // Optional overrides (only used if set)
        string(name: 'K3S_VERSION', defaultValue: '', description: 'Override k3s version (optional)')
        string(name: 'CILIUM_VERSION', defaultValue: '', description: 'Override Cilium version (optional)')
        string(name: 'CILIUM_CLI_VERSION', defaultValue: '', description: 'Override Cilium CLI version (optional)')
        string(name: 'HELM_VERSION', defaultValue: '', description: 'Override Helm version (optional)')
        string(name: 'METALLB_VERSION', defaultValue: '', description: 'Override MetalLB version (optional)')
        string(name: 'METALLB_CHART_VERSION', defaultValue: '', description: 'Override MetalLB Helm chart version (optional)')

        booleanParam(name: 'INSTALL_CILIUM', defaultValue: true, description: 'Install Cilium CNI')
        booleanParam(name: 'INSTALL_METALLB', defaultValue: true, description: 'Install MetalLB')

        booleanParam(name: 'DRY_RUN', defaultValue: false, description: 'Run in check mode (dry run)')
        booleanParam(name: 'VERBOSE', defaultValue: false, description: 'Enable verbose output')

        string(
            name: 'EXTRA_VARS',
            defaultValue: '',
            description: 'Additional Ansible variables (key=value format, space separated)'
        )
    }
    
    environment {
        REPO_DIR = params.GITHUB_REPO.tokenize('/').last().replaceAll(/\.git$/, '')
    }
    
    stages {
        stage('Preparation') {
            steps {
                script {
                    echo "🚀 Starting K3s Ansible Pipeline"
                    echo "Action: ${params.PLAYBOOK_ACTION}"
                    echo "Repository: ${params.GITHUB_REPO}"
                    echo "Branch: ${params.GITHUB_BRANCH}"
                    cleanWs()
                }
            }
        }

        stage('Install Prerequisites') {
            steps {
                script {
                    echo "📦 Installing prerequisites..."
                        sh '''
                            python3 -m venv ansible-venv
                            . ansible-venv/bin/activate
                            pip install ansible
                        '''
                }
            }
        }

        stage('Checkout Code') {
            steps {
                script {
                    // Clone the repo (let git create the folder automatically)
                    sh """
                        git config --global http.proxy http://host.docker.internal:10808
                        git config --global https.proxy http://host.docker.internal:10808

                        rm -rf ${env.REPO_DIR}
                        git clone ${params.GITHUB_REPO} -b ${params.GITHUB_BRANCH}
                        pwd
                        ls -la ${env.REPO_DIR}

                    """
                }
            }    
        }

        stage('Install Ansible Collections') {
            steps {
                    script {
                        echo "📚 Installing Ansible collections..."
                        sh """
                            . ansible-venv/bin/activate
                            ansible-galaxy collection install -r ${env.REPO_DIR}/collections/requirements.yml
                        """
                    }
            }
        }

        stage('Prepare Extra Vars') {
            steps {
                script {
                    echo "⚙️ Preparing Ansible variables..."
                    def extraVars = []

                    // Add overrides only if provided
                    if (params.K3S_VERSION?.trim()) extraVars.add("k3s_version=${params.K3S_VERSION}")
                    if (params.CILIUM_VERSION?.trim()) extraVars.add("cilium_version=${params.CILIUM_VERSION}")
                    if (params.CILIUM_CLI_VERSION?.trim()) extraVars.add("cilium_cli_version=${params.CILIUM_CLI_VERSION}")
                    if (params.HELM_VERSION?.trim()) extraVars.add("helm_version=${params.HELM_VERSION}")
                    if (params.METALLB_VERSION?.trim()) extraVars.add("metallb_version=${params.METALLB_VERSION}")
                    if (params.METALLB_CHART_VERSION?.trim()) extraVars.add("metallb_chart_version=${params.METALLB_CHART_VERSION}")

                    // Always include these toggles
                    extraVars.add("install_cilium=${params.INSTALL_CILIUM}")
                    extraVars.add("install_metallb=${params.INSTALL_METALLB}")

                    if (params.EXTRA_VARS?.trim()) {
                        extraVars.addAll(params.EXTRA_VARS.split(' '))
                    }

                    env.ANSIBLE_EXTRA_VARS = extraVars.join(' ')
                    echo "Final extra vars: ${env.ANSIBLE_EXTRA_VARS}"
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                    script {
                        echo "🎭 Running Ansible playbook..."
                        def cmd = ". ansible-venv/bin/activate && ansible-playbook"
                        def flags = ["-i ${env.REPO_DIR}/inventory.yml"]

                        if (params.DRY_RUN) { flags.add("--check --diff") }
                        if (params.VERBOSE) { flags.add("-vvv") }
                        if (env.ANSIBLE_EXTRA_VARS?.trim()) { flags.add("-e '${env.ANSIBLE_EXTRA_VARS}'") }

                        def playbookFile = ""
                        switch(params.PLAYBOOK_ACTION) {
                            case 'install-all':
                                playbookFile = "${env.REPO_DIR}/playbooks/site.yml"; break
                            case 'install-only-k3s':
                                playbookFile = "${env.REPO_DIR}/playbooks/site.yml"
                                flags.add("-e 'install_cilium=false install_metallb=false'"); break
                            case 'k3s-upgrade': playbookFile = "${env.REPO_DIR}/playbooks/upgrade.yml"; break
                            case 'reboot': playbookFile = "${env.REPO_DIR}/playbooks/reboot.yml"; break
                            case 'reset': playbookFile = "${env.REPO_DIR}/playbooks/reset.yml"; break
                            default: error "Unknown action ${params.PLAYBOOK_ACTION}"
                        }

                        def fullCmd = "${cmd} ${playbookFile} ${flags.join(' ')}"
                        echo "Executing: ${fullCmd}"

                        // REMOVE returnStatus: true and the if-check
                        sh(fullCmd)
                        
                        echo "✅ Playbook completed successfully"
                    }
            }
        }
    }

    post {
        always {
            echo "🧹 Cleaning workspace..."
            archiveArtifacts artifacts: '*.yml', allowEmptyArchive: true
            cleanWs()
        }
        success { echo "✅ Pipeline completed successfully!" }
        failure { echo "❌ Pipeline failed!" }        
    }
}