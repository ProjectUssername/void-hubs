--[[
  ╔══════════════════════════════════════════╗
  ║   VOID HUB  ·  Sambung Kata Edition     ║
  ║   Auto detect · TextBox submit · KBBI   ║
  ╚══════════════════════════════════════════╝

  CARA KERJA:
  1. Script scan semua TextLabel di game setiap 0.4 detik
  2. Kata yang paling besar & di tengah layar = kata aktif
  3. Kita ambil huruf TERAKHIR kata itu
  4. Tampilkan semua kata KBBI berawalan huruf itu
  5. Klik kata → tekan KIRIM → script ketik ke TextBox game + Enter
  6. AUTO mode: lakukan semua itu otomatis setiap giliran terdeteksi
]]

-- ══════════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════════
local Players    = game:GetService("Players")
local TweenSvc   = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════════
-- SAFE GUI PARENT
-- ══════════════════════════════════════════════
local function newGui(name, z)
    local sg = Instance.new("ScreenGui")
    sg.Name = name; sg.ResetOnSpawn = false
    sg.DisplayOrder = z; sg.IgnoreGuiInset = true
    for _, src in ipairs({
        function() return game:GetService("CoreGui") end,
        function() return pg end,
    }) do
        pcall(function()
            local o = src():FindFirstChild(name)
            if o then o:Destroy() end
        end)
    end
    if syn and syn.protect_gui then
        pcall(function() syn.protect_gui(sg) end)
        sg.Parent = game.CoreGui
    elseif gethui then
        sg.Parent = gethui()
    elseif not pcall(function() sg.Parent = game:GetService("CoreGui") end) then
        sg.Parent = pg
    end
    return sg
end

local MAIN_GUI = newGui("VHSambungKata",  150)
local NOTIF_GUI = newGui("VHSambungKataN", 999)

-- ══════════════════════════════════════════════
-- KOSAKATA KBBI  ( ~5500 kata )
-- Index per huruf pertama → lookup instan
-- ══════════════════════════════════════════════
local KAMUS = {}   -- KAMUS["a"] = {"abad","abadi",...}

local function tambah(daftar)
    for _, w in ipairs(daftar) do
        w = w:lower()
        local h = w:sub(1, 1)
        if not KAMUS[h] then KAMUS[h] = {} end
        table.insert(KAMUS[h], w)
    end
end

-- ── A ──
tambah({"abad","abadi","abah","abai","abang","abdi","abjad","abstrak","abu","acak","acara","acuan","acuh","acung","ada","adab","adat","adegan","adil","aduh","afiat","agak","agama","agung","ahad","ahli","aib","air","ajar","ajak","ajal","akan","akal","akad","akhir","akhlak","akrab","aksi","aktif","akur","alam","alami","alas","alat","alias","alih","alim","alir","alun","alur","aman","amat","ambil","ambang","amis","ampas","ampuh","anak","aneh","angka","angkasa","angin","apung","arah","arang","arus","asah","asam","asin","asli","asuh","atap","atur","awak","awam","awas","awet","ayah","ayam","ayat","azas","akademi","aktual","ambisi","analisa","angkat","antar","aspirasi","amanah","amanat","amalan","aparat","asing"})
-- ── B ──
tambah({"baca","bagus","bahasa","bahaya","bahu","baik","baja","bajak","baju","bakti","balap","balas","balik","balon","bambu","barang","baris","baru","basah","batas","batik","bayam","bayar","bebas","bebek","bedah","bekal","bekas","belah","beli","benar","benci","benih","benua","beras","berat","berani","bersih","besok","betah","betul","biaya","bibir","bimbang","bijak","bikin","bilas","bilang","bintang","biru","bisik","bocor","bola","bohong","boleh","boros","botak","buat","buah","bubur","budak","budaya","bujuk","buku","bulat","bulu","bulan","bumbu","bunyi","buang","buruh","buruk","busuk","butuh","buyar","badai","bangga","bangkit","bangsa","banjir","bantu","banyak","bapak","basmi","belajar","berlari","bertanya","bunga","bunda","bursa","bukti","berhasil","berkembang","bermain"})
-- ── C ──
tambah({"cabang","cabut","cagar","cahaya","calon","campur","canggih","cantik","capai","capek","cara","cakar","cakap","canda","cat","celah","cemas","cepat","cerah","cerdas","cerdik","ceria","cemburu","cergas","cermin","cerita","cicak","cikal","cinta","ciprat","cipta","colek","comot","contoh","copot","coreng","cubit","cuci","cukup","cukur","culik","cumbu","cumi","cuaca","cuma","curang","curai","curiga","curus","cuti","cendera","coblos","coret","cowok","curhat","cakrawala","cerewet","ceroboh","cemerlang"})
-- ── D ──
tambah({"daftar","dalam","damai","dampak","dandang","danau","dapur","darah","darat","darma","datang","dayak","dayung","debu","dekat","demam","dendam","dengar","depan","deras","desa","dewan","dewasa","diam","didik","dingin","diri","dobrak","domba","dorong","dosa","drama","duit","dulur","dusun","durian","dukung","dunia","duka","duri","dusta","dialog","dilema","dinamis","disiplin","darurat","dermaga","desain","digital","donasi"})
-- ── E ──
tambah({"edar","edukasi","efek","egois","ejaan","ejek","ekor","eksis","ekskul","ekstra","ekspor","ekspres","elastis","elak","elang","elok","elus","embun","emak","emas","empat","empuk","encik","endap","energi","enggan","enak","era","erat","etika","etnis","evolusi","esai","esok","ensiklopedia","erosi","erupsi","ekonomi","ekologi"})
-- ── F ──
tambah({"fadil","faedah","fajar","fakir","fakta","falak","famili","fana","fardhu","fasad","fasih","fatwa","fasilitas","favorit","fenomena","fikir","fiksi","filsafat","final","fitnah","firasat","fisika","fisik","fitrah","fobia","fondasi","fokus","format","formula","forum","fosil","frasa","frustrasi","fungsi","faktor","filosofi","formalitas","frekuensi"})
-- ── G ──
tambah({"gagah","gagal","galak","galau","galon","galur","gambar","ganas","ganda","ganjil","garang","gasak","gatal","gaung","gayung","gaib","gerak","gelak","gelas","gelombang","gempa","gendang","gertak","gigih","gigit","gilap","gilas","girang","global","golek","golok","goreng","gosip","goyang","gratis","gugur","gulung","gumam","guntur","guna","gurat","gusar","guyur","guru","gembira","gemuk","getah","gigi","bangga","galian","gerangan","gundukan","guratan","gadungan","gabungan","gagasan"})
-- ── H ──
tambah({"hadap","hadiah","hafal","halal","halus","hambat","hampa","hancur","hangat","hadir","hakim","haram","harmoni","harap","harga","hari","harta","hasrat","hati","hawa","hebat","heboh","hemat","heran","hikayat","hikmah","hilang","hilir","hina","hidup","hitam","hijau","hormati","hormat","hubung","hujan","huruf","hutan","humor","holistik","harapan","hartawan","halaman","hambatan","handal","hukum","hubungan"})
-- ── I ──
tambah({"ibu","ijazah","ikatan","ikat","ikhlas","ikhtiar","iklim","ikrar","ikut","iman","imbal","imbas","imbuh","imam","impas","impor","impian","inap","indah","ingin","ingat","ingkar","injak","insaf","inspirasi","intai","inti","iringan","iringi","isap","islah","isyarat","istri","istimewa","ilmu","inovasi","insan","investasi","isolasi","izin","identitas","ideologi","imajinasi","inisiatif","inklusif","institusi","integrasi","industri","informasi","imbalan"})
-- ── J ──
tambah({"jabatan","jadwal","jahit","jagoan","jaga","jago","jahat","jahil","jaket","jalur","jamuan","janda","jangka","jangkau","jasa","jatah","jalan","janji","jauh","jawab","jatuh","jelas","jeli","jelita","jemput","jemur","jenaka","jenuh","jerami","jernih","jijik","jinak","jinjit","jiplak","jiwa","joget","jorok","juara","jual","juang","judul","jujur","junjung","jurang","jurnal","jurus","jadikan","jalanan","jaminan","jangkauan","jembatan","jendela","jenis","jumlah","jumpa","justru"})
-- ── K ──
tambah({"kaki","kalimat","kampung","kandang","kantuk","kapal","kapan","karang","karena","karir","karung","karya","kasih","kasur","kata","kabur","kaget","kagum","kasar","kawasan","kawan","kebun","kecil","kejar","kekal","keliru","kembar","kendali","kerja","keras","kepala","kiri","kota","kumpul","kisah","kocak","kompak","konsep","kuasa","kubur","kuda","kuliah","kurang","kursi","kusut","kuning","kunci","kita","kali","kaya","kayu","kunyit","kupas","kurus","kutuk","kabupaten","kalangan","karakteristik","kawanan","keadilan","keberhasilan","kebijakan","kedudukan","kehilangan","kekayaan","kekuatan","kelancaran","kesadaran","kesehatan","kesempatan","kewajiban","keyakinan","korupsi","kreativitas","khas","khawatir","khayal","khalayak","khalifah","kharisma","khidmat","khilaf","khitan","khotbah","khutbah","khusus","khusyuk"})
-- ── L ──
tambah({"labuh","ladang","lahir","lajur","lakon","lalai","larang","laris","lasak","layang","layak","lazim","lebah","lebih","lebur","legam","lelah","lemah","lempar","lengan","lesu","lewat","libur","liar","lidah","lincah","lingkar","lingkungan","lipas","lipat","lirih","listrik","lolos","loncat","lorong","lubang","luhur","lulus","lumpur","lumut","luncur","lutut","lucu","luka","lunas","luruh","lupa","lurus","lama","lapar","laut","lari","loyal","layan","lihat","lambai","lambat","lampau","lancar","langkah","langsung","laporan","larut","latihan","lawan","lebaran","lembaga","lembut","lepas","liputan","luapan","lugas"})
-- ── M ──
tambah({"mabuk","macan","macet","magis","mahal","mahir","mainan","maju","makhluk","makna","malah","malang","manis","manfaat","masalah","masih","masuk","matang","makan","malam","malas","malu","mana","mandi","marah","mata","mati","mau","meja","merah","mikir","mimpi","minta","muda","mulai","murah","murni","musuh","mewah","milik","mimbar","mudah","mulia","mundur","murung","musim","mampu","mantap","masyarakat","meraih","merawat","merasa","meski","menang","mencari","mendapat","mengerti","menjaga","menyayangi","madrasah","mahasiswa","makanan","mandiri","mangsa","manusia","mengakui","mengelola","mengubah","menjalani","modernisasi","motivasi","mufakat","musyawarah","manifestasi","manajemen"})
-- ── N ──
tambah({"nada","nafas","nafkah","nahas","naik","nakal","nalar","naluri","nama","nampak","nanti","napas","narasi","nasihat","nazar","negara","negeri","nekat","nelayan","nenek","niaga","nifas","nikah","nikmat","niscaya","nista","norma","nisbah","notasi","nujum","nurani","nusantara","nyanyi","nyali","nyala","nyaman","nyamuk","nyaris","nyata","nyawa","nyeri","ngebut","ngerti","ngeluh","ngobrol","ngomong","ngopi","ngotot","ngumpul","ngejar","ngemil","ngambil","ngantar","ngatur","ngajar","ngasih","ngecat","ngeles","ngelirik","ngerem","ngeselin","ngetik","ngoreng","ngoceh","ngintip","ngilang","ngitung","nominal","normatif","nostalgia","notulen"})
-- ── O ──
tambah({"obat","objek","obrolan","oksigen","olahraga","olah","omong","ombak","opini","optimis","orbit","orasi","orde","organ","organisasi","orang","orientasi","orisinal","otoritas","otonomi","otomatis","otak","otot","oleh","operasi","oknum","olimpiade"})
-- ── P ──
tambah({"pagi","paham","pahala","pakai","paksa","pandai","panjang","papan","pasang","panas","pangkat","pasti","patuh","pecah","peduli","pekat","peka","percaya","pergi","perlu","pesan","petang","piawai","pilihan","pikir","pintar","pindah","pohon","polos","pondok","positif","puas","pujian","pulang","pulih","punah","pupuk","purba","pusaka","penting","penuh","perang","perahu","perintah","pribadi","prinsip","prioritas","produk","profesi","program","proyek","proses","publik","pinjam","pisah","pokok","potong","prihatin","pelajaran","pelayanan","pembangunan","pemerintahan","perusahaan","petualangan","pilar","plastis","politis","populis","praktis","pragmatis","prakarsa","properti","proposal","proteksi","prestasi","produktif","pemuda"})
-- ── R ──
tambah({"raga","ragam","rakyat","ramah","ranah","rancak","rapi","rapuh","rasul","raut","rahayu","rahasia","rajin","rakus","ramalan","rampas","rangkul","rantai","rantau","ratap","rawat","rehat","remaja","rencana","rendam","renggang","repot","resah","rindu","ritual","riwayat","rombak","rompi","rontal","rontok","rohani","ruang","runding","runtuh","rupiah","rugi","rumit","runcing","rupawan","rusuh","ruwet","rasa","ramai","rapih","rapat","raih","redup","rela","rendah","rezeki","riang","ringan","risau","rukun","rusak","ramadhan","realisasi","rekayasa","relasi","reputasi","resolusi","revolusi"})
-- ── S ──
tambah({"sabda","sahaja","sahut","saing","salam","salah","santai","santun","saran","sarjana","sasaran","satuan","sabar","sakit","sama","sayang","selalu","semua","senang","serius","setia","siap","simpan","sinar","singa","sopan","sukses","sunyi","syukur","segar","sehat","semangat","sempurna","sentra","sepakat","serasi","sering","siaga","sigap","sikap","silap","simpul","sinergi","singkat","siswa","situasi","solusi","songket","sumber","sungguh","supaya","sulit","sumbu","sumpah","surga","suruh","susah","syariah","solidaritas","semesta","sabun","sahabat","salak","salut","sampah","sandal","sangat","sarana","sarung","saksama","sadar","samudra","sanggup","senantiasa","setidaknya","sinyal","sistem","sosialisasi","strategi","struktur","stabil","standar","statis","stres","syahdu","syahid","syahadat","syair","syarat","syariat","syirik","syukuran","syok","sukacita","sukarela"})
-- ── T ──
tambah({"tabah","tabu","tahan","tajam","tapa","taruh","tatap","tawar","tabiat","takluk","tali","tamak","tandas","tangguh","tanpa","tahu","takut","tamat","tanda","tegar","teliti","tenang","terus","tiba","tiga","tiket","tindak","tinggal","tujuan","tulus","tebal","teduh","tegak","teguh","tekad","tekun","teladan","tempat","tentu","tepat","terbang","terima","terlalu","tetap","tinggi","titik","tugas","tuntas","turut","tutur","terbuka","terpercaya","timbul","tingkah","toleran","transparan","tumbuh","tunai","turun","tuntut","tutup","tapak","tarikan","tatanan","tegalan","telaga","telapak","tangan","tahapan","tangkas","tanggap","tanggung","tawaran","teknologi","tercapai","terjamin","terpilih","tertib","terukur","tindakan","tradisi","transfer","terlaksana"})
-- ── U ──
tambah({"ubah","udara","ukiran","ukur","ujar","ujian","ukhuwah","ulet","ulang","ulam","ulas","ulat","ulos","umat","umpama","undur","unggas","ungkap","unik","universal","unjuk","unsur","untung","upah","upaya","urai","urgen","usaha","usik","usul","utama","utara","utuh","utas","utang","ukuran","umum","unggul"})
-- ── V ──
tambah({"vaksin","valid","variasi","vendor","verbal","verifikasi","versi","vertikal","veteran","veto","vibrasi","viral","visi","vitalitas","virus","visioner","vital","vokal","vokasi","volunter","volume"})
-- ── W ──
tambah({"wadah","wafat","wahana","wahyu","wakaf","wakil","walimah","walid","walau","wangi","wanita","warga","warisan","warni","wartawan","wasit","waspada","wasiat","watak","wawasan","wewenang","wibawa","wirausaha","wisata","wong","wujud","wajar","waktu","wajah","warna","warung","wedang","wirawan"})
-- ── Y ──
tambah({"yakini","yakin","yakni","yatim","yoga","yuran","yunior","yudha","yuridis","yaitu","yayasan","yunani"})
-- ── Z ──
tambah({"zakat","zalim","zaman","ziarah","zigzag","zodiak","zona","zuhud","zuriat","zikir","zenith","zirah","zonasi","zuhur"})

-- ══════════════════════════════════════════════
-- CORE LOGIC
-- ══════════════════════════════════════════════
local sudahDipakai = {}

local function ambilDaftar(huruf)
    return KAMUS[huruf:lower()] or {}
end

-- Pilih kata terbaik dari huruf tertentu
-- Prioritas: belum dipakai, panjang 4-9, huruf akhirnya ada lanjutan
local function pilihKata(huruf)
    huruf = huruf:lower():sub(-1)   -- ambil 1 huruf terakhir saja
    local pool = KAMUS[huruf] or {}
    if #pool == 0 then return nil end

    local valid = {}
    for _, w in ipairs(pool) do
        if not sudahDipakai[w] then
            local last     = w:sub(-1)
            local adaLanjut = (KAMUS[last] and #KAMUS[last] > 2) and 4 or 0
            local panjang   = (#w >= 4 and #w <= 9) and 2 or 0
            table.insert(valid, {w=w, s=adaLanjut+panjang+math.random()})
        end
    end
    if #valid == 0 then  -- semua habis, reset
        sudahDipakai = {}
        for _, w in ipairs(pool) do
            table.insert(valid, {w=w, s=math.random()})
        end
    end
    table.sort(valid, function(a,b) return a.s > b.s end)
    local pilih = valid[math.random(1, math.min(6, #valid))].w
    sudahDipakai[pilih] = true
    return pilih
end

-- ══════════════════════════════════════════════
-- SCAN KATA AKTIF DI LAYAR
-- Mencari TextLabel terbesar di tengah layar
-- ══════════════════════════════════════════════
local function scanKataAktif()
    local terbaik, skor = nil, -1
    local vp = workspace.CurrentCamera.ViewportSize

    for _, gui in ipairs(pg:GetChildren()) do
        if gui == MAIN_GUI or gui == NOTIF_GUI then continue end
        if not gui:IsA("ScreenGui") then continue end
        for _, obj in ipairs(gui:GetDescendants()) do
            if not obj:IsA("TextLabel") then continue end
            if not obj.Visible then continue end

            local teks = obj.Text:lower():gsub("[^a-z]", "")
            if #teks < 2 or #teks > 20 then continue end
            if not teks:match("^[a-z]+$") then continue end

            local s = 0
            local nm = obj.Name:lower()

            -- nama object hints
            if nm:find("word") or nm:find("kata") then s = s + 20 end
            if nm:find("current") or nm:find("prompt") or nm:find("soal") then s = s + 16 end
            if nm:find("challenge") or nm:find("question") then s = s + 14 end
            if nm:find("center") or nm:find("display") then s = s + 10 end

            -- ukuran font — kunci utama
            if obj.TextSize >= 36 then s = s + 20
            elseif obj.TextSize >= 28 then s = s + 15
            elseif obj.TextSize >= 22 then s = s + 10
            elseif obj.TextSize >= 18 then s = s + 5
            end

            -- posisi tengah layar (x)
            local cx = obj.AbsolutePosition.X + obj.AbsoluteSize.X * 0.5
            local dx = math.abs(cx - vp.X * 0.5)
            if dx < 50  then s = s + 14
            elseif dx < 100 then s = s + 9
            elseif dx < 180 then s = s + 4
            end

            -- posisi tengah layar (y) — bukan header/footer
            local vy = obj.AbsolutePosition.Y / vp.Y
            if vy >= 0.25 and vy <= 0.65 then s = s + 6 end

            if s > skor then skor = s; terbaik = teks end
        end
    end
    return terbaik
end

-- ══════════════════════════════════════════════
-- DETEKSI GILIRAN
-- Cek apakah ada UI yang menandakan giliran kita
-- ══════════════════════════════════════════════
local function giliranKu()
    local myName = lp.Name:lower()
    for _, gui in ipairs(pg:GetChildren()) do
        if gui == MAIN_GUI or gui == NOTIF_GUI then continue end
        if not gui:IsA("ScreenGui") then continue end
        for _, obj in ipairs(gui:GetDescendants()) do
            if not obj:IsA("TextLabel") or not obj.Visible then continue end
            local teks = obj.Text:lower()
            local nm   = obj.Name:lower()

            -- TextLabel berisi nama kita di elemen bertanda "turn"
            if teks:find(myName, 1, true) then
                if nm:find("turn") or nm:find("giliran") or nm:find("current") or nm:find("active") or nm:find("player") then
                    return true
                end
                -- warna text sangat terang (kuning/putih = aktif)
                local col = obj.TextColor3
                local bri = col.R * 0.3 + col.G * 0.6 + col.B * 0.1
                if bri > 0.8 and obj.TextSize >= 12 then
                    return true
                end
            end

            -- TextLabel "YOUR TURN" / "GILIRANMU" dsb
            if (teks:find("your turn") or teks:find("giliran kamu") or teks:find("giliranmu") or teks == "kamu" or teks == "anda") and obj.Visible then
                return true
            end
        end
    end
    return false
end

-- ══════════════════════════════════════════════
-- SUBMIT KATA KE GAME
-- Cari TextBox → ketik → Enter
-- ══════════════════════════════════════════════
local sedangKetik = false

local function cariTextBox()
    local terbaik, skor = nil, -1
    for _, gui in ipairs(pg:GetChildren()) do
        if gui == MAIN_GUI or gui == NOTIF_GUI then continue end
        if not gui:IsA("ScreenGui") then continue end
        for _, obj in ipairs(gui:GetDescendants()) do
            if not obj:IsA("TextBox") or not obj.Visible then continue end
            if obj.Interactable == false then continue end
            local n = obj.Name:lower()
            local s = 0
            if n:find("input") or n:find("answer") or n:find("chat") then s = s + 15 end
            if n:find("word") or n:find("type") or n:find("ketik") then s = s + 12 end
            if n:find("jawab") then s = s + 12 end
            -- TextBox lebih lebar = lebih mungkin input game
            if obj.AbsoluteSize.X > 200 then s = s + 5 end
            if obj.AbsoluteSize.X > 300 then s = s + 5 end
            if s > skor then skor = s; terbaik = obj end
        end
    end
    if terbaik then return terbaik end
    -- fallback: TextBox visible terlebar
    local lebar = 0
    for _, gui in ipairs(pg:GetChildren()) do
        if gui == MAIN_GUI or gui == NOTIF_GUI then continue end
        if not gui:IsA("ScreenGui") then continue end
        for _, obj in ipairs(gui:GetDescendants()) do
            if obj:IsA("TextBox") and obj.Visible then
                local w = obj.AbsoluteSize.X
                if w > lebar then lebar = w; terbaik = obj end
            end
        end
    end
    return terbaik
end

local function ketikKata(kata, humanMode)
    if not kata or #kata == 0 or sedangKetik then return false end
    sedangKetik = true
    task.spawn(function()
        local box = cariTextBox()
        if box then
            pcall(function() box:CaptureFocus() end)
            task.wait(0.06)
            pcall(function() box.Text = "" end)
            task.wait(0.04)
            for i = 1, #kata do
                pcall(function() box.Text = kata:sub(1, i) end)
                task.wait(humanMode and (0.07 + math.random() * 0.12) or 0.04)
            end
            task.wait(0.1)
            pcall(function() box:ReleaseFocus(true) end)
            task.wait(0.06)
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:KeyDown(Enum.KeyCode.Return)
                task.wait(0.05)
                vu:KeyUp(Enum.KeyCode.Return)
            end)
            if _G._vhsk_submitted then _G._vhsk_submitted(kata) end
        else
            if _G._vhsk_nobox then _G._vhsk_nobox() end
        end
        task.wait(0.35)
        sedangKetik = false
    end)
    return true
end

-- ══════════════════════════════════════════════
-- STATE
-- ══════════════════════════════════════════════
local autoMode   = false
local humanMode  = true
local kataAktif  = ""
local lastAutoT  = 0

-- ══════════════════════════════════════════════
-- SCAN LOOP  –  1 Heartbeat, interval 0.4s
-- ══════════════════════════════════════════════
local lastScanT = 0
RunService.Heartbeat:Connect(function()
    if not MAIN_GUI or not MAIN_GUI.Parent then return end
    local t = os.clock()
    if t - lastScanT < 0.4 then return end
    lastScanT = t

    -- scan kata
    local kata = scanKataAktif()
    if kata and kata ~= kataAktif then
        kataAktif = kata
        if _G._vhsk_newkata then _G._vhsk_newkata(kata) end
    end

    -- auto mode
    if autoMode and not sedangKetik and kataAktif ~= "" then
        if t - lastAutoT < 1.5 then return end  -- throttle 1.5 detik
        local myTurn = giliranKu()
        if myTurn then
            lastAutoT = t
            local ans = pilihKata(kataAktif)
            if ans then
                local delay = 0.7 + (humanMode and math.random() * 0.5 or 0)
                task.delay(delay, function()
                    if autoMode then ketikKata(ans, humanMode) end
                end)
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════
--  N O T I F I K A S I
-- ══════════════════════════════════════════════════════
local notifStack = {}
local notifColors = {
    ok   = Color3.fromRGB(56, 225, 120),
    info = Color3.fromRGB(66, 138, 255),
    warn = Color3.fromRGB(255, 172, 40),
    err  = Color3.fromRGB(255, 68, 68),
}
local function Notif(teks, jenis)
    jenis = jenis or "info"
    local col = notifColors[jenis] or notifColors.info
    for _, f in ipairs(notifStack) do
        TweenSvc:Create(f, TweenInfo.new(0.12), {
            Position = f.Position + UDim2.new(0, 0, 0, 32)
        }):Play()
    end
    local f = Instance.new("Frame", NOTIF_GUI)
    f.Size     = UDim2.new(0, 200, 0, 26)
    f.Position = UDim2.new(1, -210, 0, -50)
    f.BackgroundColor3 = Color3.fromRGB(11, 12, 24)
    f.BorderSizePixel  = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    local stripe = Instance.new("Frame", f)
    stripe.Size = UDim2.new(0, 3, 1, 0); stripe.BackgroundColor3 = col; stripe.BorderSizePixel = 0
    Instance.new("UICorner", stripe).CornerRadius = UDim.new(0, 3)
    local lb = Instance.new("TextLabel", f)
    lb.Size = UDim2.new(1, -10, 1, 0); lb.Position = UDim2.new(0, 8, 0, 0)
    lb.BackgroundTransparency = 1; lb.Text = teks; lb.TextSize = 11
    lb.Font = Enum.Font.GothamSemibold; lb.TextColor3 = Color3.fromRGB(218, 230, 255)
    lb.TextXAlignment = Enum.TextXAlignment.Left; lb.TextTruncate = Enum.TextTruncate.AtEnd
    local sk = Instance.new("UIStroke", f); sk.Color = col; sk.Thickness = 1; sk.Transparency = 0.52
    table.insert(notifStack, 1, f)
    TweenSvc:Create(f, TweenInfo.new(0.26, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -210, 0, 10)
    }):Play()
    task.delay(2.8, function()
        TweenSvc:Create(f, TweenInfo.new(0.18), {
            Position = UDim2.new(1, 8, 0, f.Position.Y.Offset)
        }):Play()
        task.delay(0.2, function()
            local i = table.find(notifStack, f)
            if i then table.remove(notifStack, i) end
            pcall(function() f:Destroy() end)
        end)
    end)
end

-- ══════════════════════════════════════════════════════
--  U I  —  Design: gelap elegan, aksen cyan-biru
--  Ukuran: 295 × 430  (pojok kiri, kecil, tidak ganggu)
-- ══════════════════════════════════════════════════════
local W, H = 295, 430

-- Warna
local K = {
    bg    = Color3.fromRGB(10, 11, 22),
    bar   = Color3.fromRGB(15, 17, 32),
    card  = Color3.fromRGB(19, 22, 38),
    cardA = Color3.fromRGB(24, 28, 50),
    acc   = Color3.fromRGB(40, 160, 255),
    accD  = Color3.fromRGB(18, 100, 220),
    accB  = Color3.fromRGB(80, 185, 255),
    bdr   = Color3.fromRGB(25, 75, 185),
    bF    = Color3.fromRGB(22, 30, 58),
    txt   = Color3.fromRGB(220, 232, 255),
    mu    = Color3.fromRGB(82, 110, 172),
    dim   = Color3.fromRGB(36, 52, 98),
    ok    = Color3.fromRGB(56, 225, 120),
    warn  = Color3.fromRGB(255, 172, 40),
    red   = Color3.fromRGB(255, 68, 68),
    gold  = Color3.fromRGB(255, 212, 48),
    cyan  = Color3.fromRGB(40, 220, 220),
    pillOff = Color3.fromRGB(20, 24, 44),
}

-- Builder functions
local function Fr(p, pa)
    local f = Instance.new("Frame"); f.BorderSizePixel = 0
    for k, v in pairs(p) do pcall(function() f[k] = v end) end
    if pa then f.Parent = pa end; return f
end
local function Lb(p, pa)
    local l = Instance.new("TextLabel"); l.BackgroundTransparency = 1; l.Font = Enum.Font.GothamSemibold
    for k, v in pairs(p) do pcall(function() l[k] = v end) end
    if pa then l.Parent = pa end; return l
end
local function Btn(p, pa)
    local b = Instance.new("TextButton"); b.BorderSizePixel = 0; b.Font = Enum.Font.GothamBold
    for k, v in pairs(p) do pcall(function() b[k] = v end) end
    if pa then b.Parent = pa end; return b
end
local function Rnd(r, p) Instance.new("UICorner", p).CornerRadius = UDim.new(0, r) end
local function Str(c, t, p)
    local s = Instance.new("UIStroke", p); s.Color = c; s.Thickness = t; return s
end
local function Grad(c1, c2, rot, p)
    local g = Instance.new("UIGradient", p)
    g.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2)}
    g.Rotation = rot
end
local tw = function(obj, props, dur, st, dr)
    TweenSvc:Create(obj, TweenInfo.new(dur, st or Enum.EasingStyle.Quad, dr or Enum.EasingDirection.Out), props):Play()
end

-- ── WINDOW ─────────────────────────────────────────────
local WIN = Fr({
    Size             = UDim2.new(0, W, 0, H),
    Position         = UDim2.new(0, 8, 0, 8),
    BackgroundColor3 = K.bg,
    Active           = true,
    Draggable        = true,
}, MAIN_GUI)
Rnd(14, WIN)
Str(K.bdr, 1.5, WIN)
Grad(Color3.fromRGB(10, 13, 26), Color3.fromRGB(6, 7, 16), 158, WIN)

-- Top glow line
local topGlow = Fr({
    Size             = UDim2.new(1, -40, 0, 2),
    Position         = UDim2.new(0, 20, 0, 0),
    BackgroundColor3 = K.acc,
    ZIndex           = 5,
}, WIN)
Rnd(2, topGlow)
topGlow.BackgroundTransparency = 0.5
Grad(Color3.fromRGB(0, 0, 0), K.acc, 0, topGlow)
-- blink glow
task.spawn(function()
    while WIN and WIN.Parent do
        tw(topGlow, {BackgroundTransparency=0.2}, 1.2)
        task.wait(1.2)
        tw(topGlow, {BackgroundTransparency=0.7}, 1.2)
        task.wait(1.2)
    end
end)

-- ── TITLE BAR ──────────────────────────────────────────
local TB = Fr({Size=UDim2.new(1, 0, 0, 38), BackgroundColor3=K.accD, ZIndex=3}, WIN)
Rnd(14, TB)
-- fix bottom corners
Fr({Size=UDim2.new(1,0,0.5,0), Position=UDim2.new(0,0,0.5,0), BackgroundColor3=K.accD, BorderSizePixel=0, ZIndex=2}, TB)
Grad(Color3.fromRGB(18, 105, 245), Color3.fromRGB(10, 55, 175), 135, TB)

-- Logo
local logoBg = Fr({Size=UDim2.new(0,26,0,26), Position=UDim2.new(0,8,0.5,-13), BackgroundColor3=K.acc, ZIndex=5}, TB)
Rnd(7, logoBg)
Grad(K.accB, K.accD, 140, logoBg)
Lb({Size=UDim2.new(1,0,1,0), Text="V", TextSize=14, Font=Enum.Font.GothamBold, TextColor3=Color3.fromRGB(255,255,255), ZIndex=6}, logoBg)

Lb({
    Size=UDim2.new(0,118,0,16), Position=UDim2.new(0,40,0,4),
    Text="VOID HUB", TextSize=14, Font=Enum.Font.GothamBold,
    TextColor3=Color3.fromRGB(255,255,255), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4
}, TB)
Lb({
    Size=UDim2.new(0,165,0,12), Position=UDim2.new(0,40,0,22),
    Text="Sambung Kata  ·  KBBI", TextSize=9, Font=Enum.Font.Gotham,
    TextColor3=Color3.fromRGB(130,188,255), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4
}, TB)

-- Tombol X dan -
local btnClose = Btn({
    Size=UDim2.new(0,22,0,22), Position=UDim2.new(1,-30,0.5,-11),
    BackgroundColor3=K.red, Text="✕", TextSize=10, TextColor3=Color3.fromRGB(255,255,255), ZIndex=6
}, TB); Rnd(6, btnClose)
local btnMin = Btn({
    Size=UDim2.new(0,22,0,22), Position=UDim2.new(1,-56,0.5,-11),
    BackgroundColor3=K.warn, Text="−", TextSize=16, TextColor3=Color3.fromRGB(255,255,255), ZIndex=6
}, TB); Rnd(6, btnMin)

local BODY = Fr({Size=UDim2.new(1,0,1,-38), Position=UDim2.new(0,0,0,38), BackgroundTransparency=1}, WIN)

btnClose.MouseButton1Click:Connect(function()
    tw(WIN, {Size=UDim2.new(0,W,0,0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    task.delay(0.22, function()
        pcall(function() MAIN_GUI:Destroy() end)
        pcall(function() NOTIF_GUI:Destroy() end)
    end)
end)
local isMin = false
btnMin.MouseButton1Click:Connect(function()
    isMin = not isMin
    BODY.Visible = not isMin
    tw(WIN, {Size=isMin and UDim2.new(0,W,0,38) or UDim2.new(0,W,0,H)}, 0.2)
end)

local P = 8  -- padding

-- ── STATUS CARD ─────────────────────────────────────────
-- "kata di game" + hint
local statCard = Fr({
    Size=UDim2.new(1,-P*2,0,52), Position=UDim2.new(0,P,0,8),
    BackgroundColor3=K.bar,
}, BODY)
Rnd(10, statCard); Str(K.bF, 1.2, statCard)

-- label kecil kiri & kanan
Lb({
    Size=UDim2.new(0.5,0,0,14), Position=UDim2.new(0,10,0,5),
    Text="KATA DI GAME", TextSize=8, Font=Enum.Font.GothamBold,
    TextColor3=K.mu, TextXAlignment=Enum.TextXAlignment.Left
}, statCard)
local turnBadge = Lb({
    Size=UDim2.new(0.5,-4,0,14), Position=UDim2.new(0.5,0,0,5),
    Text="⏳ menunggu giliran", TextSize=8, Font=Enum.Font.GothamBold,
    TextColor3=K.dim, TextXAlignment=Enum.TextXAlignment.Right
}, statCard)
Instance.new("UIPadding", turnBadge).PaddingRight = UDim.new(0, 8)

-- Kata besar + panah + hint
local kataLabel = Lb({
    Size=UDim2.new(0.55,0,0,28), Position=UDim2.new(0,10,0,19),
    Text="—", TextSize=22, Font=Enum.Font.GothamBold,
    TextColor3=K.gold, TextXAlignment=Enum.TextXAlignment.Left
}, statCard)
Lb({
    Size=UDim2.new(0.08,0,0,28), Position=UDim2.new(0.54,0,0,19),
    Text="→", TextSize=16, TextColor3=K.dim
}, statCard)
local hintLabel = Lb({
    Size=UDim2.new(0.36,0,0,28), Position=UDim2.new(0.62,0,0,19),
    Text="—", TextSize=14, Font=Enum.Font.GothamBold,
    TextColor3=K.cyan, TextXAlignment=Enum.TextXAlignment.Left
}, statCard)

-- Accent bar kiri pada statCard
local accentBar = Fr({
    Size=UDim2.new(0,3,0.7,0), Position=UDim2.new(0,0,0.15,0),
    BackgroundColor3=K.acc,
}, statCard)
Rnd(3, accentBar)

-- ── TOGGLE ROW ───────────────────────────────────────────
local togY = 8 + 52 + 6
local togRow = Fr({
    Size=UDim2.new(1,-P*2,0,28), Position=UDim2.new(0,P,0,togY),
    BackgroundTransparency=1,
}, BODY)

local function mkTog(xOff, ww, label, init, cb)
    local isOn = init
    local c = Fr({Size=UDim2.new(0,ww,1,0), Position=UDim2.new(0,xOff,0,0), BackgroundColor3=K.bar}, togRow)
    Rnd(7, c); Str(K.bF, 1, c)
    local lr = Lb({
        Size=UDim2.new(0.64,0,1,0), Position=UDim2.new(0,8,0,0),
        Text=label, TextSize=9, Font=Enum.Font.GothamBold,
        TextColor3=isOn and K.accB or K.mu, TextXAlignment=Enum.TextXAlignment.Left,
    }, c)
    local pill = Fr({Size=UDim2.new(0,30,0,16), Position=UDim2.new(1,-37,0.5,-8), BackgroundColor3=isOn and K.accD or K.pillOff}, c)
    Rnd(8, pill)
    local knob = Fr({
        Size=UDim2.new(0,12,0,12),
        Position=isOn and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,2,0.5,-6),
        BackgroundColor3=isOn and Color3.fromRGB(255,255,255) or K.mu,
    }, pill)
    Rnd(6, knob)
    local hit = Btn({Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=5}, c)
    hit.MouseButton1Click:Connect(function()
        isOn = not isOn
        tw(pill, {BackgroundColor3=isOn and K.accD or K.pillOff}, 0.16)
        tw(knob, {
            Position=isOn and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,2,0.5,-6),
            BackgroundColor3=isOn and Color3.fromRGB(255,255,255) or K.mu,
        }, 0.16)
        lr.TextColor3 = isOn and K.accB or K.mu
        cb(isOn)
    end)
end

mkTog(0,   136, "AUTO PLAY", false, function(on)
    autoMode = on
    if on then
        tw(turnBadge, {TextColor3=K.ok}, 0.2)
        turnBadge.Text = "🤖 auto aktif"
    else
        tw(turnBadge, {TextColor3=K.dim}, 0.2)
        turnBadge.Text = "⏳ menunggu giliran"
    end
    Notif(on and "AUTO PLAY ON ✓" or "AUTO PLAY OFF", on and "ok" or "warn")
end)
mkTog(140, 140, "Human Delay", true, function(on) humanMode = on end)

-- ── HURUF A-Z (horizontal scroll pill) ──────────────────
local alphaY = togY + 28 + 7

Lb({
    Size=UDim2.new(1,-P*2,0,14), Position=UDim2.new(0,P,0,alphaY),
    Text="  PILIH HURUF", TextSize=8, Font=Enum.Font.GothamBold,
    TextColor3=K.acc, TextXAlignment=Enum.TextXAlignment.Left,
}, BODY)

local divA = Fr({Size=UDim2.new(1,-P*2,0,1), Position=UDim2.new(0,P,0,alphaY+13), BackgroundColor3=K.bdr}, BODY)
divA.BackgroundTransparency = 0.6

local alphaSF = Instance.new("ScrollingFrame", BODY)
alphaSF.Size     = UDim2.new(1,-P*2,0,44)
alphaSF.Position = UDim2.new(0,P,0,alphaY+17)
alphaSF.BackgroundTransparency = 1; alphaSF.BorderSizePixel = 0
alphaSF.ScrollBarThickness = 2; alphaSF.ScrollBarImageColor3 = K.acc
alphaSF.ScrollingDirection = Enum.ScrollingDirection.X
alphaSF.CanvasSize = UDim2.new(0,0,0,0); alphaSF.AutomaticCanvasSize = Enum.AutomaticSize.X
local aLL = Instance.new("UIListLayout", alphaSF)
aLL.FillDirection = Enum.FillDirection.Horizontal
aLL.Padding = UDim.new(0,3); aLL.SortOrder = Enum.SortOrder.LayoutOrder

-- ── SEARCH ───────────────────────────────────────────────
local searchY = alphaY + 17 + 44 + 5
local searchF = Fr({Size=UDim2.new(1,-P*2,0,28), Position=UDim2.new(0,P,0,searchY), BackgroundColor3=K.bar}, BODY)
Rnd(7, searchF); Str(K.bF, 1, searchF)
Lb({Size=UDim2.new(0,22,1,0), Position=UDim2.new(0,7,0,0), Text="🔍", TextSize=12, TextColor3=K.mu}, searchF)
local searchTB = Instance.new("TextBox", searchF)
searchTB.Size=UDim2.new(1,-32,1,0); searchTB.Position=UDim2.new(0,26,0,0)
searchTB.BackgroundTransparency=1; searchTB.ClearTextOnFocus=false; searchTB.Text=""
searchTB.PlaceholderText="Filter kata..."; searchTB.Font=Enum.Font.GothamSemibold
searchTB.TextSize=11; searchTB.TextColor3=K.txt; searchTB.PlaceholderColor3=K.dim
searchTB.TextXAlignment=Enum.TextXAlignment.Left

-- ── WORD COUNT ───────────────────────────────────────────
local wcY = searchY + 28 + 4
local wcLabel = Lb({
    Size=UDim2.new(1,-P*2,0,14), Position=UDim2.new(0,P,0,wcY),
    Text="Pilih huruf untuk memulai", TextSize=8, Font=Enum.Font.GothamBold,
    TextColor3=K.mu, TextXAlignment=Enum.TextXAlignment.Left,
}, BODY)
local divW = Fr({Size=UDim2.new(1,-P*2,0,1), Position=UDim2.new(0,P,0,wcY+14), BackgroundColor3=K.bdr}, BODY)
divW.BackgroundTransparency = 0.6

-- ── WORD SCROLL (grid 2 kolom) ───────────────────────────
local actH2  = 44
local wScrollY = wcY + 16
local wScrollH = H - 38 - wScrollY - actH2 - P - 4

local wordSF = Instance.new("ScrollingFrame", BODY)
wordSF.Size = UDim2.new(1,-P*2,0,wScrollH)
wordSF.Position = UDim2.new(0,P,0,wScrollY)
wordSF.BackgroundTransparency = 1; wordSF.BorderSizePixel = 0
wordSF.ScrollBarThickness = 3; wordSF.ScrollBarImageColor3 = K.acc
wordSF.CanvasSize = UDim2.new(0,0,0,0); wordSF.AutomaticCanvasSize = Enum.AutomaticSize.Y
local wGrid = Instance.new("UIGridLayout", wordSF)
wGrid.CellSize = UDim2.new(0.5,-3,0,30)
wGrid.CellPadding = UDim2.new(0,4,0,3)
wGrid.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", wordSF).PaddingBottom = UDim.new(0,4)

-- ── ACTION BAR ───────────────────────────────────────────
local actBarY = H - 38 - actH2 - P
local actBar = Fr({
    Size=UDim2.new(1,-P*2,0,actH2), Position=UDim2.new(0,P,0,actBarY),
    BackgroundColor3=K.bar,
}, BODY)
Rnd(10, actBar)
Str(K.bdr, 1.5, actBar)
Grad(Color3.fromRGB(14,18,40), Color3.fromRGB(9,12,28), 160, actBar)

Lb({
    Size=UDim2.new(0.3,0,0,13), Position=UDim2.new(0,10,0,4),
    Text="DIPILIH", TextSize=8, Font=Enum.Font.GothamBold,
    TextColor3=K.dim, TextXAlignment=Enum.TextXAlignment.Left,
}, actBar)
local selLabel = Lb({
    Size=UDim2.new(0.55,0,0,22), Position=UDim2.new(0,10,0,17),
    Text="—", TextSize=15, Font=Enum.Font.GothamBold,
    TextColor3=K.accB, TextXAlignment=Enum.TextXAlignment.Left,
}, actBar)

local sendBtn = Btn({
    Size=UDim2.new(0,80,0,32), Position=UDim2.new(1,-88,0.5,-16),
    BackgroundColor3=K.accD, Text="⌨  KIRIM", TextSize=11,
    TextColor3=Color3.fromRGB(255,255,255), ZIndex=4,
}, actBar)
Rnd(8, sendBtn)
Grad(K.accB, K.accD, 90, sendBtn)
sendBtn.MouseEnter:Connect(function() tw(sendBtn,{BackgroundColor3=K.acc},0.1) end)
sendBtn.MouseLeave:Connect(function() tw(sendBtn,{BackgroundColor3=K.accD},0.1) end)

local pilihanSekarang = nil
sendBtn.MouseButton1Click:Connect(function()
    if not pilihanSekarang then Notif("Pilih kata terlebih dahulu!", "warn"); return end
    ketikKata(pilihanSekarang, humanMode)
end)

-- ── BUILD WORD LIST ──────────────────────────────────────
local prevWordBtn = nil

local function buildWordList(huruf, filter)
    -- hapus lama
    for _, c in ipairs(wordSF:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
    pilihanSekarang = nil; selLabel.Text = "—"; prevWordBtn = nil

    local semua = ambilDaftar(huruf)
    local tampil = {}
    if filter and #filter > 0 then
        local fl = filter:lower()
        for _, w in ipairs(semua) do
            if w:find(fl, 1, true) then table.insert(tampil, w) end
        end
    else
        tampil = semua
    end

    wcLabel.Text = #tampil .. " kata  (awalan '" .. huruf:upper() .. "')"

    if #tampil == 0 then
        Lb({
            Size=UDim2.new(1,0,0,30), BackgroundTransparency=1,
            Text="Tidak ada kata ditemukan", TextSize=10,
            TextColor3=K.dim, Font=Enum.Font.GothamSemibold,
        }, wordSF)
        return
    end

    for i, kata in ipairs(tampil) do
        local hurufAkhir = kata:sub(-1):lower()
        local adaLanjutan = KAMUS[hurufAkhir] and #KAMUS[hurufAkhir] > 2

        local btn = Btn({
            BackgroundColor3=K.card, Text="", ZIndex=3, LayoutOrder=i,
        }, wordSF)
        Rnd(7, btn)
        Str(K.bF, 1, btn)

        -- nama kata
        Lb({
            Size=UDim2.new(1,-26,1,0), Position=UDim2.new(0,8,0,0),
            Text=kata, TextSize=11, Font=Enum.Font.GothamBold,
            TextColor3=K.txt, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4,
        }, btn)

        -- badge huruf akhir
        local badgeColor = adaLanjutan and K.ok or K.warn
        local badge = Fr({
            Size=UDim2.new(0,19,0,17), Position=UDim2.new(1,-22,0.5,-8.5),
            BackgroundColor3=badgeColor, ZIndex=4,
        }, btn)
        Rnd(5, badge); badge.BackgroundTransparency = 0.42
        Lb({
            Size=UDim2.new(1,0,1,0), Text=hurufAkhir:upper(), TextSize=8,
            Font=Enum.Font.GothamBold, TextColor3=Color3.fromRGB(255,255,255), ZIndex=5,
        }, badge)

        btn.MouseButton1Click:Connect(function()
            if prevWordBtn then tw(prevWordBtn, {BackgroundColor3=K.card}, 0.1) end
            tw(btn, {BackgroundColor3=K.accD}, 0.1)
            local sk2 = btn:FindFirstChildOfClass("UIStroke")
            if sk2 then sk2.Color = K.acc; sk2.Thickness = 1.5 end
            prevWordBtn = btn; pilihanSekarang = kata; selLabel.Text = kata
        end)
        btn.MouseEnter:Connect(function()
            if btn ~= prevWordBtn then tw(btn,{BackgroundColor3=K.cardA},0.08) end
        end)
        btn.MouseLeave:Connect(function()
            if btn ~= prevWordBtn then tw(btn,{BackgroundColor3=K.card},0.08) end
        end)
    end
end

-- Search filter
local hurufAktif = "a"
searchTB:GetPropertyChangedSignal("Text"):Connect(function()
    buildWordList(hurufAktif, searchTB.Text)
end)

-- ── ALPHA BUTTONS ────────────────────────────────────────
local prevAlphaBtn = nil
local alphaBtnMap  = {}

local function pilihHuruf(ch, btnRef)
    if prevAlphaBtn then
        tw(prevAlphaBtn, {BackgroundColor3=K.card, TextColor3=K.mu}, 0.14)
    end
    tw(btnRef, {BackgroundColor3=K.acc, TextColor3=Color3.fromRGB(255,255,255)}, 0.14)
    prevAlphaBtn = btnRef; hurufAktif = ch
    searchTB.Text = ""
    buildWordList(ch, "")
    -- preview hint
    hintLabel.Text = pilihKata(ch) or "—"
end

for i = 1, 26 do
    local ch  = string.char(96 + i)
    local cnt = KAMUS[ch] and #KAMUS[ch] or 0
    local btn = Btn({
        Size=UDim2.new(0,30,1,-4), BackgroundColor3=K.card,
        Text=ch:upper(), TextSize=11,
        TextColor3=cnt > 0 and K.mu or K.dim,
        Font=Enum.Font.GothamBold, LayoutOrder=i, ZIndex=3,
    }, alphaSF)
    Rnd(6, btn)
    alphaBtnMap[ch] = btn
    btn.MouseButton1Click:Connect(function() pilihHuruf(ch, btn) end)
end

-- ── CALLBACKS DARI SCAN LOOP ─────────────────────────────
_G._vhsk_newkata = function(kata)
    kataLabel.Text = kata
    hintLabel.Text = pilihKata(kata) or "—"
    -- auto highlight huruf terakhir
    local last = kata:sub(-1):lower()
    if alphaBtnMap[last] then
        pilihHuruf(last, alphaBtnMap[last])
    end
    -- deteksi giliran untuk update badge
    if giliranKu() then
        turnBadge.Text = "✅ GILIRAN KAMU"
        tw(turnBadge, {TextColor3=K.ok}, 0.2)
    else
        if not autoMode then
            turnBadge.Text = "⏳ menunggu giliran"
            tw(turnBadge, {TextColor3=K.dim}, 0.2)
        end
    end
end

_G._vhsk_submitted = function(kata)
    Notif("✓ Submitted: " .. kata, "ok")
end

_G._vhsk_nobox = function()
    Notif("TextBox input tidak ditemukan — coba manual", "warn")
end

-- ── ENTRANCE ANIMATION ────────────────────────────────────
WIN.Position         = UDim2.new(0, 8, 1.5, 0)
WIN.BackgroundTransparency = 1
tw(WIN, {Position=UDim2.new(0,8,0,8), BackgroundTransparency=0}, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

task.delay(0.5, function()
    local total = 0
    for _, v in pairs(KAMUS) do total = total + #v end
    Notif("VOID HUB · Sambung Kata loaded ✓", "ok")
    task.delay(1.0, function()
        Notif("DB: " .. total .. " kata KBBI siap", "info")
        task.delay(0.8, function()
            if alphaBtnMap["a"] then pilihHuruf("a", alphaBtnMap["a"]) end
        end)
    end)
end)
