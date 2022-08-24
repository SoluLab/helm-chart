{{- define "setup" }}
    #!/bin/sh
    function createAdmin {

    echo
    echo "Enroll the CA admin"
    echo
    mkdir -p organizations/peerOrganizations/admin/

    export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/admin/

    set -x
    fabric-ca-client enroll -u https://admin:Loxnetwork%40123@admin-ca-svc:7054 --caname admin-ca --tls.certfiles ${PWD}/organizations/fabric-ca/adminOrg/tls-cert.pem
    set +x

    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/admin-ca-svc-7054-admin-ca.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/admin-ca-svc-7054-admin-ca.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/admin-ca-svc-7054-admin-ca.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/admin-ca-svc-7054-admin-ca.pem
        OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/admin/msp/config.yaml

    echo
    echo "Register peer1"
    echo
    set -x
    fabric-ca-client register --caname admin-ca --id.name peer1 --id.secret peer1pw --id.type peer --id.attrs '"hf.Registrar.Roles=peer"' --tls.certfiles ${PWD}/organizations/fabric-ca/adminOrg/tls-cert.pem
    set +x

    echo
    echo "Register peer2"
    echo
    set -x
    fabric-ca-client register --caname admin-ca --id.name peer2 --id.secret peer2pw --id.type peer --id.attrs '"hf.Registrar.Roles=peer"' --tls.certfiles ${PWD}/organizations/fabric-ca/adminOrg/tls-cert.pem
    set +x

    echo
    echo "Register user"
    echo
    set -x
    fabric-ca-client register --caname admin-ca --id.name user1 --id.secret user1pw --id.type client --id.attrs '"hf.Registrar.Roles=client"' --tls.certfiles ${PWD}/organizations/fabric-ca/adminOrg/tls-cert.pem
    set +x

    echo
    echo "Register the org admin"
    echo
    set -x
    fabric-ca-client register --caname admin-ca --id.name adminAdmin --id.secret Loxnetwork@123 --id.type admin --id.attrs '"hf.Registrar.Roles=admin"' --tls.certfiles ${PWD}/organizations/fabric-ca/adminOrg/tls-cert.pem
    set +x

    mkdir -p organizations/peerOrganizations/admin/peers
    mkdir -p organizations/peerOrganizations/admin/peers/peer1-admin
    mkdir -p organizations/peerOrganizations/admin/peers/peer2-admin

    echo
    echo "## Generate the peer1 msp"
    echo
    set -x
    fabric-ca-client enroll -u https://peer1:peer1pw@admin-ca-svc:7054 --caname admin-ca -M ${PWD}/organizations/peerOrganizations/admin/peers/peer1-admin/msp --csr.hosts peer1-admin-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/adminOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/peerOrganizations/admin/msp/config.yaml ${PWD}/organizations/peerOrganizations/admin/peers/peer1-admin/msp/config.yaml

    echo
    echo "## Generate the peer2 msp"
    echo
    set -x
    fabric-ca-client enroll -u https://peer2:peer2pw@admin-ca-svc:7054 --caname admin-ca -M ${PWD}/organizations/peerOrganizations/admin/peers/peer2-admin/msp --csr.hosts peer2-admin-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/adminOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/peerOrganizations/admin/msp/config.yaml ${PWD}/organizations/peerOrganizations/admin/peers/peer2-admin/msp/config.yaml

    echo
    echo "## Generate the peer1-tls certificates"
    echo
    set -x
    fabric-ca-client enroll -u https://peer1:peer1pw@admin-ca-svc:7054 --caname admin-ca -M ${PWD}/organizations/peerOrganizations/admin/peers/peer1-admin/tls --enrollment.profile tls --csr.hosts peer1-admin-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/adminOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/peerOrganizations/admin/peers/peer1-admin/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/admin/peers/peer1-admin/tls/ca.crt
    cp ${PWD}/organizations/peerOrganizations/admin/peers/peer1-admin/tls/signcerts/* ${PWD}/organizations/peerOrganizations/admin/peers/peer1-admin/tls/server.crt
    cp ${PWD}/organizations/peerOrganizations/admin/peers/peer1-admin/tls/keystore/* ${PWD}/organizations/peerOrganizations/admin/peers/peer1-admin/tls/server.key

    mkdir ${PWD}/organizations/peerOrganizations/admin/msp/tlscacerts
    cp ${PWD}/organizations/peerOrganizations/admin/peers/peer1-admin/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/admin/msp/tlscacerts/ca.crt

    mkdir ${PWD}/organizations/peerOrganizations/admin/tlsca
    cp ${PWD}/organizations/peerOrganizations/admin/peers/peer1-admin/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/admin/tlsca/tlsca.admin-cert.pem

    mkdir ${PWD}/organizations/peerOrganizations/admin/ca
    cp ${PWD}/organizations/peerOrganizations/admin/peers/peer1-admin/msp/cacerts/* ${PWD}/organizations/peerOrganizations/admin/ca/ca.admin-cert.pem

    echo
    echo "## Generate the peer2-tls certificates"
    echo
    set -x
    fabric-ca-client enroll -u https://peer2:peer2pw@admin-ca-svc:7054 --caname admin-ca -M ${PWD}/organizations/peerOrganizations/admin/peers/peer2-admin/tls --enrollment.profile tls --csr.hosts peer2-admin-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/adminOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/peerOrganizations/admin/peers/peer2-admin/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/admin/peers/peer2-admin/tls/ca.crt
    cp ${PWD}/organizations/peerOrganizations/admin/peers/peer2-admin/tls/signcerts/* ${PWD}/organizations/peerOrganizations/admin/peers/peer2-admin/tls/server.crt
    cp ${PWD}/organizations/peerOrganizations/admin/peers/peer2-admin/tls/keystore/* ${PWD}/organizations/peerOrganizations/admin/peers/peer2-admin/tls/server.key

    mkdir -p organizations/peerOrganizations/admin/users
    mkdir -p organizations/peerOrganizations/admin/users/User1@admin

    echo
    echo "## Generate the user msp"
    echo
    set -x
    fabric-ca-client enroll -u https://user1:user1pw@admin-ca-svc:7054 --caname admin-ca -M ${PWD}/organizations/peerOrganizations/admin/users/User1@admin/msp --tls.certfiles ${PWD}/organizations/fabric-ca/adminOrg/tls-cert.pem
    set +x

    mkdir -p organizations/peerOrganizations/admin/users/Admin@admin

    echo
    echo "## Generate the org admin msp"
    echo
    set -x
    fabric-ca-client enroll -u https://adminAdmin:Loxnetwork%40123@admin-ca-svc:7054 --caname admin-ca -M ${PWD}/organizations/peerOrganizations/admin/users/Admin@admin/msp --tls.certfiles ${PWD}/organizations/fabric-ca/adminOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/peerOrganizations/admin/msp/config.yaml ${PWD}/organizations/peerOrganizations/admin/users/Admin@admin/msp/config.yaml
    }

    function createUser {

    echo
    echo "Enroll the CA admin"
    echo
    mkdir -p organizations/peerOrganizations/user/

    export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/user/

    set -x
    fabric-ca-client enroll -u https://admin:Loxnetwork%40123@user-ca-svc:7054 --caname user-ca --tls.certfiles ${PWD}/organizations/fabric-ca/userOrg/tls-cert.pem
    set +x

    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/user-ca-svc-7054-user-ca.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/user-ca-svc-7054-user-ca.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/user-ca-svc-7054-user-ca.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/user-ca-svc-7054-user-ca.pem
        OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/user/msp/config.yaml

    echo
    echo "Register peer1"
    echo
    set -x
    fabric-ca-client register --caname user-ca --id.name peer1 --id.secret peer1pw --id.type peer --id.attrs '"hf.Registrar.Roles=peer"' --tls.certfiles ${PWD}/organizations/fabric-ca/userOrg/tls-cert.pem
    set +x

    echo
    echo "Register peer2"
    echo
    set -x
    fabric-ca-client register --caname user-ca --id.name peer2 --id.secret peer2pw --id.type peer --id.attrs '"hf.Registrar.Roles=peer"' --tls.certfiles ${PWD}/organizations/fabric-ca/userOrg/tls-cert.pem
    set +x

    echo
    echo "Register user"
    echo
    set -x
    fabric-ca-client register --caname user-ca --id.name user1 --id.secret user1pw --id.type client --id.attrs '"hf.Registrar.Roles=client"' --tls.certfiles ${PWD}/organizations/fabric-ca/userOrg/tls-cert.pem
    set +x

    echo
    echo "Register the org admin"
    echo
    set -x
    fabric-ca-client register --caname user-ca --id.name userAdmin --id.secret Loxnetwork@123 --id.type admin --id.attrs '"hf.Registrar.Roles=admin"' --tls.certfiles ${PWD}/organizations/fabric-ca/userOrg/tls-cert.pem
    set +x

    mkdir -p organizations/peerOrganizations/user/peers
    mkdir -p organizations/peerOrganizations/user/peers/peer1-user
    mkdir -p organizations/peerOrganizations/user/peers/peer2-user

    echo
    echo "## Generate the peer1 msp"
    echo
    set -x
    fabric-ca-client enroll -u https://peer1:peer1pw@user-ca-svc:7054 --caname user-ca -M ${PWD}/organizations/peerOrganizations/user/peers/peer1-user/msp --csr.hosts peer1-user-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/userOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/peerOrganizations/user/msp/config.yaml ${PWD}/organizations/peerOrganizations/user/peers/peer1-user/msp/config.yaml

    echo
    echo "## Generate the peer2 msp"
    echo
    set -x
    fabric-ca-client enroll -u https://peer2:peer2pw@user-ca-svc:7054 --caname user-ca -M ${PWD}/organizations/peerOrganizations/user/peers/peer2-user/msp --csr.hosts peer2-user-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/userOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/peerOrganizations/user/msp/config.yaml ${PWD}/organizations/peerOrganizations/user/peers/peer2-user/msp/config.yaml

    echo
    echo "## Generate the peer1-tls certificates"
    echo
    set -x
    fabric-ca-client enroll -u https://peer1:peer1pw@user-ca-svc:7054 --caname user-ca -M ${PWD}/organizations/peerOrganizations/user/peers/peer1-user/tls --enrollment.profile tls --csr.hosts peer1-user-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/userOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/peerOrganizations/user/peers/peer1-user/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/user/peers/peer1-user/tls/ca.crt
    cp ${PWD}/organizations/peerOrganizations/user/peers/peer1-user/tls/signcerts/* ${PWD}/organizations/peerOrganizations/user/peers/peer1-user/tls/server.crt
    cp ${PWD}/organizations/peerOrganizations/user/peers/peer1-user/tls/keystore/* ${PWD}/organizations/peerOrganizations/user/peers/peer1-user/tls/server.key

    mkdir ${PWD}/organizations/peerOrganizations/user/msp/tlscacerts
    cp ${PWD}/organizations/peerOrganizations/user/peers/peer1-user/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/user/msp/tlscacerts/ca.crt

    mkdir ${PWD}/organizations/peerOrganizations/user/tlsca
    cp ${PWD}/organizations/peerOrganizations/user/peers/peer1-user/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/user/tlsca/tlsca.user-cert.pem

    mkdir ${PWD}/organizations/peerOrganizations/user/ca
    cp ${PWD}/organizations/peerOrganizations/user/peers/peer1-user/msp/cacerts/* ${PWD}/organizations/peerOrganizations/user/ca/ca.user-cert.pem

    echo
    echo "## Generate the peer2-tls certificates"
    echo
    set -x
    fabric-ca-client enroll -u https://peer2:peer2pw@user-ca-svc:7054 --caname user-ca -M ${PWD}/organizations/peerOrganizations/user/peers/peer2-user/tls --enrollment.profile tls --csr.hosts peer2-user-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/userOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/peerOrganizations/user/peers/peer2-user/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/user/peers/peer2-user/tls/ca.crt
    cp ${PWD}/organizations/peerOrganizations/user/peers/peer2-user/tls/signcerts/* ${PWD}/organizations/peerOrganizations/user/peers/peer2-user/tls/server.crt
    cp ${PWD}/organizations/peerOrganizations/user/peers/peer2-user/tls/keystore/* ${PWD}/organizations/peerOrganizations/user/peers/peer2-user/tls/server.key

    mkdir -p organizations/peerOrganizations/user/users
    mkdir -p organizations/peerOrganizations/user/users/User1@user

    echo
    echo "## Generate the user msp"
    echo
    set -x
    fabric-ca-client enroll -u https://user1:user1pw@user-ca-svc:7054 --caname user-ca -M ${PWD}/organizations/peerOrganizations/user/users/User1@user/msp --tls.certfiles ${PWD}/organizations/fabric-ca/userOrg/tls-cert.pem
    set +x

    mkdir -p organizations/peerOrganizations/user/users/Admin@user

    echo
    echo "## Generate the org user msp"
    echo
    set -x
    fabric-ca-client enroll -u https://userAdmin:Loxnetwork%40123@user-ca-svc:7054 --caname user-ca -M ${PWD}/organizations/peerOrganizations/user/users/Admin@user/msp --tls.certfiles ${PWD}/organizations/fabric-ca/userOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/peerOrganizations/user/msp/config.yaml ${PWD}/organizations/peerOrganizations/user/users/Admin@user/msp/config.yaml

    }

    function createOrderer {

    echo
    echo "Enroll the CA admin"
    echo
    mkdir -p organizations/ordererOrganizations/ordererOrg

    export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/ordererOrg

    set -x
    fabric-ca-client enroll -u https://admin:Loxnetwork%40123@orderer-ca-svc:7054 --caname orderer-ca --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/orderer-ca-svc-7054-orderer-ca.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/orderer-ca-svc-7054-orderer-ca.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/orderer-ca-svc-7054-orderer-ca.pem

        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/orderer-ca-svc-7054-orderer-ca.pem
        OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/ordererOrganizations/ordererOrg/msp/config.yaml


    echo
    echo "Register orderer1"
    echo
    set -x
    fabric-ca-client register --caname orderer-ca --id.name orderer1 --id.secret orderer1pw --id.type orderer --id.attrs '"hf.Registrar.Roles=orderer"' --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    echo
    echo "Register ordere2"
    echo
    set -x
    fabric-ca-client register --caname orderer-ca --id.name orderer2 --id.secret orderer2pw --id.type orderer --id.attrs '"hf.Registrar.Roles=orderer"' --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    echo
    echo "Register orderer3"
    echo
    set -x
    fabric-ca-client register --caname orderer-ca --id.name orderer3 --id.secret orderer3pw --id.type orderer --id.attrs '"hf.Registrar.Roles=orderer"' --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    echo
    echo "Register orderer4"
    echo
    set -x
    fabric-ca-client register --caname orderer-ca --id.name orderer4 --id.secret orderer4pw --id.type orderer --id.attrs '"hf.Registrar.Roles=orderer"' --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    echo
    echo "Register orderer5"
    echo
    set -x
    fabric-ca-client register --caname orderer-ca --id.name orderer5 --id.secret orderer5pw --id.type orderer --id.attrs '"hf.Registrar.Roles=orderer"' --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x


    echo
    echo "Register the orderer admin"
    echo
    set -x
    fabric-ca-client register --caname orderer-ca --id.name ordererAdmin --id.secret Loxnetwork@123 --id.type admin --id.attrs '"hf.Registrar.Roles=admin"' --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    mkdir -p organizations/ordererOrganizations/ordererOrg/orderers
    mkdir -p organizations/ordererOrganizations/ordererOrg/orderers/admin

    mkdir -p organizations/ordererOrganizations/ordererOrg/orderers/orderer1
    mkdir -p organizations/ordererOrganizations/ordererOrg/orderers/orderer2
    mkdir -p organizations/ordererOrganizations/ordererOrg/orderers/orderer3
    mkdir -p organizations/ordererOrganizations/ordererOrg/orderers/orderer4
    mkdir -p organizations/ordererOrganizations/ordererOrg/orderers/orderer5

    echo
    echo "## Generate the orderer1 msp"
    echo
    set -x
    fabric-ca-client enroll -u https://orderer1:orderer1pw@orderer-ca-svc:7054 --caname orderer-ca -M ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer1/msp --csr.hosts orderer1-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/msp/config.yaml ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer1/msp/config.yaml

    echo
    echo "## Generate the orderer2 msp"
    echo
    set -x
    fabric-ca-client enroll -u https://orderer2:orderer2pw@orderer-ca-svc:7054 --caname orderer-ca -M ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer2/msp --csr.hosts orderer2-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/msp/config.yaml ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer2/msp/config.yaml

    echo
    echo "## Generate the orderer3 msp"
    echo
    set -x
    fabric-ca-client enroll -u https://orderer3:orderer3pw@orderer-ca-svc:7054 --caname orderer-ca -M ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer3/msp --csr.hosts orderer3-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/msp/config.yaml ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer3/msp/config.yaml

    echo
    echo "## Generate the orderer4 msp"
    echo
    set -x
    fabric-ca-client enroll -u https://orderer4:orderer4pw@orderer-ca-svc:7054 --caname orderer-ca -M ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer4/msp --csr.hosts orderer4-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/msp/config.yaml ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer4/msp/config.yaml

    echo
    echo "## Generate the orderer5 msp"
    echo
    set -x
    fabric-ca-client enroll -u https://orderer5:orderer5pw@orderer-ca-svc:7054 --caname orderer-ca -M ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer5/msp --csr.hosts orderer5-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/msp/config.yaml ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer5/msp/config.yaml


    echo
    echo "## Generate the orderer1-tls certificates"
    echo
    set -x
    fabric-ca-client enroll -u https://orderer1:orderer1pw@orderer-ca-svc:7054 --caname orderer-ca -M ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer1/tls --enrollment.profile tls --csr.hosts orderer1-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer1/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer1/tls/ca.crt
    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer1/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer1/tls/server.crt
    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer1/tls/keystore/* ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer1/tls/server.key

    mkdir ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer1/msp/tlscacerts
    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer1/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer1/msp/tlscacerts/tlsca.orderer-cert.pem

    mkdir ${PWD}/organizations/ordererOrganizations/ordererOrg/msp/tlscacerts
    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer1/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/ordererOrg/msp/tlscacerts/tlsca.orderer-cert.pem

    mkdir ${PWD}/organizations/ordererOrganizations/ordererOrg/msp/tlscacerts
    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer1/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/ordererOrg/msp/tlscacerts/tlsca.orderer-cert.pem

    echo
    echo "## Generate the orderer2-tls certificates"
    echo
    set -x
    fabric-ca-client enroll -u https://orderer2:orderer2pw@orderer-ca-svc:7054 --caname orderer-ca -M ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer2/tls --enrollment.profile tls --csr.hosts orderer2-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer2/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer2/tls/ca.crt
    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer2/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer2/tls/server.crt
    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer2/tls/keystore/* ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer2/tls/server.key

    echo
    echo "## Generate the orderer3-tls certificates"
    echo
    set -x
    fabric-ca-client enroll -u https://orderer3:orderer3pw@orderer-ca-svc:7054 --caname orderer-ca -M ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer3/tls --enrollment.profile tls --csr.hosts orderer3-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer3/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer3/tls/ca.crt
    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer3/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer3/tls/server.crt
    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer3/tls/keystore/* ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer3/tls/server.key

    echo
    echo "## Generate the orderer4-tls certificates"
    echo
    set -x
    fabric-ca-client enroll -u https://orderer4:orderer4pw@orderer-ca-svc:7054 --caname orderer-ca -M ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer4/tls --enrollment.profile tls --csr.hosts orderer4-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer4/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer4/tls/ca.crt
    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer4/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer4/tls/server.crt
    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer4/tls/keystore/* ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer4/tls/server.key

    echo
    echo "## Generate the orderer5-tls certificates"
    echo
    set -x
    fabric-ca-client enroll -u https://orderer5:orderer5pw@orderer-ca-svc:7054 --caname orderer-ca -M ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer5/tls --enrollment.profile tls --csr.hosts orderer5-svc.hyperledger.svc.cluster.local --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer5/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer5/tls/ca.crt
    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer5/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer5/tls/server.crt
    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer5/tls/keystore/* ${PWD}/organizations/ordererOrganizations/ordererOrg/orderers/orderer5/tls/server.key

    mkdir -p organizations/ordererOrganizations/ordererOrg/users
    mkdir -p organizations/ordererOrganizations/ordererOrg/users/Admin@orderer

    echo
    echo "## Generate the admin msp"
    echo
    set -x
    fabric-ca-client enroll -u https://ordererAdmin:Loxnetwork%40123@orderer-ca-svc:7054 --caname orderer-ca -M ${PWD}/organizations/ordererOrganizations/ordererOrg/users/Admin@orderer/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

    cp ${PWD}/organizations/ordererOrganizations/ordererOrg/msp/config.yaml ${PWD}/organizations/ordererOrganizations/ordererOrg/users/Admin@orderer/msp/config.yaml

    }
{{- end }}