// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract University {
    
    // 1. تعريف المتغيرات الأساسية
    address public admin; // عنوان محفظة الجامعة

    // 2. هيكل بيانات الشهادة
    struct Certificate {
        address student;   // محفظة الطالب
        bool isValid;      // حالة الشهادة (صالحة/ملغاة)
        uint256 issueDate; // تاريخ الإصدار بتوقيت البلوكشين
    }

    // 3. قاعدة البيانات (الخريطة)
    // نربط الهاش (bytes32) بهيكل الشهادة
    mapping(bytes32 => Certificate) public certificates;

    // 4. الأحداث (Events) - لإعلام العالم الخارجي عند حدوث فعل
    event CertificateIssued(bytes32 indexed certHash, address indexed student);
    event CertificateRevoked(bytes32 indexed certHash);

    // 5. حارس البوابة (Modifier)
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only University Admin can perform this action");
        _;
    }

    // 6. المنشئ (Constructor) - يعمل مرة واحدة عند الرفع
    constructor() {
        admin = msg.sender; // الشخص الذي يرفع العقد هو المدير
    }

    // 7. وظيفة إصدار الشهادة
    function issueCertificate(bytes32 _certHash, address _student) public onlyAdmin {
        // التأكد أن الهاش لم يسبق استخدامه (تاريخ الإصدار 0 يعني غير موجودة)
        require(certificates[_certHash].issueDate == 0, "Certificate hash already exists");
        
        // تخزين البيانات في الـ Mapping
        certificates[_certHash] = Certificate({
            student: _student,
            isValid: true,
            issueDate: block.timestamp
        });

        emit CertificateIssued(_certHash, _student);
    }

    // 8. وظيفة إلغاء الشهادة (Revocation)
    function revokeCertificate(bytes32 _certHash) public onlyAdmin {
        require(certificates[_certHash].issueDate != 0, "Certificate does not exist");
        require(certificates[_certHash].isValid == true, "Certificate is already revoked");

        certificates[_certHash].isValid = false; // تغيير الحالة إلى غير صالحة

        emit CertificateRevoked(_certHash);
    }

    // 9. وظيفة التحقق (Verification)
    // هذه الوظيفة "view" لأنها لا تغير البيانات، وبالتالي لا تستهلك Gas عند الاستعلام
    function verifyCertificate(bytes32 _certHash) public view returns (bool, address, uint256) {
        Certificate memory cert = certificates[_certHash];
        require(cert.issueDate != 0, "Certificate not found on blockchain");
        
        return (cert.isValid, cert.student, cert.issueDate);
    }
}