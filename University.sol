// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract University {
    
    // 1. State Variables
    address public admin; // Address of the university authority

    // 2. Certificate Data Structure
    struct Certificate {
        address student;   // Wallet address of the student
        bool isValid;      // Status of the certificate (Active/Revoked)
        uint256 issueDate; // Timestamp of issuance on the blockchain
    }

    // 3. Database (Mapping)
    // Linking the digital hash (bytes32) to the Certificate structure
    mapping(bytes32 => Certificate) public certificates;

    // 4. Events - To notify the external world (Frontend/Indexers) of actions
    event CertificateIssued(bytes32 indexed certHash, address indexed student);
    event CertificateRevoked(bytes32 indexed certHash);

    // 5. Access Control (Modifier)
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only University Admin can perform this action");
        _;
    }

    // 6. Constructor - Executes once upon deployment
    constructor() {
        admin = msg.sender; 
    }

    // 7. Certificate Issuance Function
    function issueCertificate(bytes32 _certHash, address _student) public onlyAdmin {
        // Validation: Ensure the hash has not been used before
        require(certificates[_certHash].issueDate == 0, "Certificate hash already exists");
        
        // Storing data in the Blockchain Mapping
        certificates[_certHash] = Certificate({
            student: _student,
            isValid: true,
            issueDate: block.timestamp
        });

        emit CertificateIssued(_certHash, _student);
    }

    // 8. Certificate Revocation Function
    function revokeCertificate(bytes32 _certHash) public onlyAdmin {
        require(certificates[_certHash].issueDate != 0, "Certificate does not exist");
        require(certificates[_certHash].isValid == true, "Certificate is already revoked");

        // Changing the state to invalid (Revocation logic)
        certificates[_certHash].isValid = false; 

        emit CertificateRevoked(_certHash);
    }

    // 9. Verification Function
    function verifyCertificate(bytes32 _certHash) public view returns (bool, address, uint256) {
        Certificate memory cert = certificates[_certHash];
        require(cert.issueDate != 0, "Certificate not found on blockchain");
        
        return (cert.isValid, cert.student, cert.issueDate);
    }

}
