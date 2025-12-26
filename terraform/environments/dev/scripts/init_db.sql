-- ========================================
-- Bebee 개발 환경 MySQL 초기 데이터베이스 생성
-- ========================================
--
-- 이 스크립트는 RDS가 생성된 후 자동 실행됩니다.
-- Bebee 서비스에 필요한 모든 마이크로 서비스별 데이터베이스를 생성합니다.
--
-- 마스터 사용자: root (RDS 생성 시 자동 생성됨)
-- 추가 사용자: bebee (이 스크립트에서 생성)
--
-- 설정 값:
-- - CHARACTER SET utf8mb4: 이모지 및 다국어 지원을 위한 4바이트 유니코드 설정
-- - COLLATE utf8mb4_unicode_ci: 대소문자 비구분(Case-Insensitive) 정렬 방식 설정

-- bebee 애플리케이션 사용자 생성
CREATE USER IF NOT EXISTS 'bebee'@'%'
    IDENTIFIED BY 'bebee1234';


-- 1. bebee_member: 회원 관리 서비스 DB
CREATE DATABASE IF NOT EXISTS bebee_member
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 2. bebee_match: 매칭 로직 서비스 DB
CREATE DATABASE IF NOT EXISTS bebee_match
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 3. bebee_chat: 채팅 서비스 DB
CREATE DATABASE IF NOT EXISTS bebee_chat
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 4. bebee_notification: 알림/푸시 서비스 DB
CREATE DATABASE IF NOT EXISTS bebee_notification
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 5. bebee_payment: 결제 및 정산 서비스 DB
CREATE DATABASE IF NOT EXISTS bebee_payment
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;


-- ========================================
-- Bebee 개발 환경 MySQL 권한 설정
-- ========================================

-- 사용자 bebee 에 bebee_chat 데이터베이스에 대한 권한 설정
GRANT ALL PRIVILEGES ON bebee_chat.* TO 'bebee'@'%';

-- 사용자 bebee 에 bebee_member 데이터베이스에 대한 권한 설정
GRANT ALL PRIVILEGES ON bebee_member.* TO 'bebee'@'%';

-- 사용자 bebee 에 bebee_match 데이터베이스에 대한 권한 설정
GRANT ALL PRIVILEGES ON bebee_match.* TO 'bebee'@'%';

-- 사용자 bebee 에 bebee_notification 데이터베이스에 대한 권한 설정
GRANT ALL PRIVILEGES ON bebee_notification.* TO 'bebee'@'%';

-- 사용자 bebee 에 bebee_payment 데이터베이스에 대한 권한 설정
GRANT ALL PRIVILEGES ON bebee_payment.* TO 'bebee'@'%';

-- 권한 적용
FLUSH PRIVILEGES;

-- 생성 확인 쿼리
-- 모든 'bebee_'로 시작하는 데이터베이스 목록을 표시하여 생성을 확인합니다.
SHOW DATABASES LIKE 'bebee_%';