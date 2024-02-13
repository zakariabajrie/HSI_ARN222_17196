-- 1.b. cek database yang sedang digunakan
USE HSI_ARN222_17196;
SELECT DATABASE() AS Database_yang_sedang_digunakan;

-- 1.c. cek versi database
SELECT VERSION() AS versi_mariadb;

-- 2. membuat tabel Peserta sesuai ketentuan
CREATE TABLE peserta (
    nip VARCHAR(12) NOT NULL,
    nama_depan VARCHAR(50) NOT NULL,
    nama_belakang VARCHAR(50) NOT NULL,
    tempat_lahir VARCHAR(50) NOT NULL,
    tanggal_lahir DATE NOT NULL,
    nomor_telepon VARCHAR(16) NOT NULL,
    email VARCHAR(50),
    domisili VARCHAR(50) NOT NULL,
    alamat VARCHAR(200),
    created_at TIMESTAMP NOT NULL,
    update_at TIMESTAMP,
    PRIMARY KEY(nip)
);

-- 3.a. menampilkan 10 data teratas setelah insert data
SELECT * FROM peserta LIMIT 10;

-- 3.b. update pada kolom domisili sesuai ketentuan
UPDATE peserta
SET domisili = (CASE 
    WHEN domisili = 'Jakarta' THEN '001'
    WHEN domisili = 'Bekasi' THEN '002'
    WHEN domisili = 'Depok' THEN '003'
    WHEN domisili = 'Bogor' THEN '004'
    WHEN domisili = 'Tangerang' THEN '005'
    WHEN domisili = 'Aceh' THEN '006'
    WHEN domisili = 'Medan' THEN '007'
    WHEN domisili = 'Pekanbaru' THEN '008'
    WHEN domisili = 'Padang' THEN '009'
    WHEN domisili = 'Bandung' THEN '010'
    END),
    update_at = NOW()
WHERE domisili IN ('Jakarta', 'Bekasi', 'Depok', 'Bogor', 'Tangerang', 'Aceh', 'Medan', 'Pekanbaru', 'Padang', 'Bandung');

-- 3.b. menampilkan data setelah update
SELECT *
FROM peserta
WHERE domisili BETWEEN '001' AND '010'
LIMIT 15;

-- 3.c. delete data berdasarkan domisili yang tidak ditentukan
DELETE FROM peserta
WHERE domisili NOT BETWEEN '001' AND '010';

-- 3.c. mengecek data yang dihapus, apakah masih dalam tabel peserta atau tidak
SELECT *
FROM peserta
WHERE domisili NOT BETWEEN '001' AND '010';

-- membuat table domisili
CREATE TABLE domisili (
    id_domisili VARCHAR(50) NOT NULL,
    kota VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_domisili)
);

-- 4.a. jumlah peserta per domisili
SELECT d.kota domisili, COUNT(*) AS jumlah
FROM peserta p JOIN domisili d
ON p.domisili = d.id_domisili
GROUP BY p.domisili;

-- 4.b. jumlah peserta per domisili yang lahir antara tahun 1950 - 1990
SELECT d.kota domisili, COUNT(*) jumlah_peserta_antara_1950_1990
FROM peserta p JOIN domisili d
ON p.domisili = d.id_domisili
WHERE YEAR(p.tanggal_lahir) BETWEEN 1950 AND 1990
GROUP BY p.domisili;


-- 4.c. jumlah peserta per bulan (pada kolom tanggal lahir) yang lahir antara tahun 1991 - 2013 yang domisilinya berada di jabodetabek
SELECT MONTH(tanggal_lahir) AS bulan, COUNT(*) AS jumlah
FROM peserta
WHERE (YEAR(tanggal_lahir) BETWEEN 1991 AND 2013) AND (domisili BETWEEN '001' AND '005')
GROUP BY MONTH(tanggal_lahir);

SELECT MONTH(tanggal_lahir) AS bulan, COUNT(*) AS jumlah
FROM peserta
GROUP BY MONTHNAME(tanggal_lahir), MONTH(tanggal_lahir)
ORDER BY MONTH(tanggal_lahir);


-- catatan
-- setelah mengumpulkan

DESCRIBE peserta;

-- 4.c.
SELECT tanggal_lahir, domisili
FROM peserta
WHERE domisili in ('001', '002', '003', '004', '005') AND YEAR(tanggal_lahir) BETWEEN 1991 AND 2013
ORDER BY MONTH(tanggal_lahir);

SELECT EXTRACT(MONTH(tanggal_lahir))
FROM peserta;

SELECT MONTHNAME(tanggal_lahir) AS bulan, COUNT(*) AS jumlah
FROM peserta
WHERE (YEAR(tanggal_lahir) BETWEEN 1991 AND 2013) AND (domisili BETWEEN '001' AND '005')
GROUP BY MONTHNAME(tanggal_lahir), MONTH(tanggal_lahir)
ORDER BY MONTH(tanggal_lahir);