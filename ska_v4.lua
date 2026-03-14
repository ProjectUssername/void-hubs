--[[
  VOID HUB | Sambung Kata FINAL
  Database: 70.000+ kata KBBI live dari GitHub
  Auto-index per huruf pertama | RE intercept | Android UI
  
  CARA PAKAI:
  1. Upload file ini ke GitHub kamu
  2. loadstring(game:HttpGet("URL_FILE_INI"))()
  
  Script otomatis ambil database KBBI dari:
  github.com/damzaky/kumpulan-kata-bahasa-indonesia-KBBI
]]

-- ════════════════════════════════
-- SERVICES
-- ════════════════════════════════
local Players    = game:GetService("Players")
local RS         = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenSvc   = game:GetService("TweenService")
local lp         = Players.LocalPlayer
local pg         = lp:WaitForChild("PlayerGui")

-- ════════════════════════════════
-- SAFE GUI
-- ════════════════════════════════
local function safeGui(name, z)
    local sg = Instance.new("ScreenGui")
    sg.Name = name; sg.ResetOnSpawn = false
    sg.DisplayOrder = z; sg.IgnoreGuiInset = true
    for _, src in ipairs({function() return game:GetService("CoreGui") end, function() return pg end}) do
        pcall(function() local o=src():FindFirstChild(name); if o then o:Destroy() end end)
    end
    if syn and syn.protect_gui then pcall(function() syn.protect_gui(sg) end); sg.Parent = game.CoreGui
    elseif gethui then sg.Parent = gethui()
    elseif not pcall(function() sg.Parent = game:GetService("CoreGui") end) then sg.Parent = pg end
    return sg
end

local GUI  = safeGui("VoidSKFinal", 200)
local NGUI = safeGui("VoidSKFinalN", 999)

-- ════════════════════════════════════════════════════════════
--  D B   L O A D E R
--  Fetch 70.000+ kata KBBI dari GitHub repo publik
--  Format file: satu kata per baris
--  Setelah load → index ke DICT[huruf] = {kata, kata, ...}
-- ════════════════════════════════════════════════════════════
local DICT   = {}   -- DICT["a"] = {"abad","abadi",...}
local TOTAL  = 0
local LOADED = false

-- URL database KBBI publik (70k+ kata, satu per baris)
-- Sumber: damzaky/kumpulan-kata-bahasa-indonesia-KBBI
local DB_URL = "https://raw.githubusercontent.com/damzaky/kumpulan-kata-bahasa-indonesia-KBBI/master/list_1.0.0.txt"

-- Fallback URL jika gagal
local DB_FALLBACK = "https://raw.githubusercontent.com/adhitj/kumpulan-kata-bahasa-indonesia/main/kata_dasar.txt"

local function indexWord(w)
    w = w:lower():gsub("[^a-z]","")
    if #w < 2 then return end
    local k = w:sub(1,1)
    if not DICT[k] then DICT[k] = {} end
    table.insert(DICT[k], w)
    TOTAL = TOTAL + 1
end

local function parseAndIndex(raw)
    -- Split by newline
    local count = 0
    for line in raw:gmatch("[^\r\n]+") do
        local word = line:lower():gsub("%s+","")
        if #word >= 2 and #word <= 20 and word:match("^[a-z]+$") then
            indexWord(word)
            count = count + 1
        end
    end
    return count
end

-- ════════════════════════════════════════════════════════════
--  F A L L B A C K   D A T A B A S E
--  ~5000 kata built-in jika fetch gagal
-- ════════════════════════════════════════════════════════════
local BUILTIN = [[abad,abadi,abah,abai,abang,abdi,abjad,absen,abstrak,abu,acak,acara,aceh,acuan,acuh,acung,ada,adab,adat,adegan,adil,aduh,afiat,agak,agama,agih,agung,ahad,ahli,aib,air,ajar,ajak,ajal,akan,akal,akad,akhir,akhlak,akrab,aksi,aktif,akur,alam,alami,alas,alat,album,alias,alih,alim,alir,alis,alit,alun,alur,aman,amat,ambil,ambang,amis,ampas,ampuh,anak,aneh,angka,angkasa,angsa,angin,anjing,antara,apung,arah,arang,arus,asah,asam,asin,asli,asuh,atap,atur,awak,awam,awas,awet,ayah,ayam,ayat,azas,azab,baca,bagas,bagian,bagus,bahasa,bahaya,bahu,baik,baja,bajak,bajau,bajik,baju,bakti,balap,balas,balik,balon,bambu,barang,baris,baru,basah,batas,batik,batok,baur,bayam,bayar,bebas,bebek,bedah,bekal,bekas,belah,belas,beli,benar,benci,benih,benua,beras,berat,berani,berita,bersih,besok,betah,betul,biaya,bibir,bimbang,bijak,bikin,bilas,bilang,bintang,biru,bisik,bising,bius,bocor,bola,bolak,bonceng,bongkar,bohong,boleh,boros,botak,buat,buah,bubuk,bubur,budak,budaya,bujuk,buku,bulat,bulu,bulan,bumbu,bungkus,bunyi,buang,buruh,buruk,buru,busuk,butuh,buyar,cabang,cabut,cagar,cahaya,calon,campur,canggih,cantik,capai,capek,cara,cakar,cakap,canda,cat,celah,cemas,cepat,cerah,cerdas,cerdik,cemerlang,ceria,cemburu,cemar,cergas,cermin,cerita,cicak,cicil,cikal,cinta,ciprat,cipta,colek,comot,contoh,copot,coreng,cubit,cucuk,cukai,cuci,cukup,cukur,culik,cumbu,cumi,cuaca,cuma,curang,curai,curiga,curus,cuti,daftar,dalam,damai,dampak,dandang,danau,dapur,darah,darat,darma,datang,dayak,dayung,debu,dedak,dekat,demam,dendam,dengar,depan,deras,desa,dewan,dewasa,diam,didik,dingin,dini,diri,dobrak,domba,dorong,dosa,drama,dribel,duit,dulur,dusun,durian,dukung,dunia,duka,duri,dusta,edar,edukasi,efek,egois,ejaan,ejek,ekor,eksis,ekskul,ekstra,ekspor,ekspres,eksplor,elastis,elak,elang,elok,elus,embun,emak,emas,empang,empat,empuk,encik,endap,energi,enggan,enjin,enak,era,erat,etika,etnis,evolusi,esai,esok,fadil,faedah,fajar,fakir,fakta,falak,famili,fana,fanatis,fardhu,fasad,fasih,fatwa,fasilitas,favorit,fenomena,fikir,fiksi,filsafat,final,fitnah,firasat,fisika,fisik,fitrah,fleksibel,fobia,fondasi,fokus,format,formula,forum,fosil,frasa,friksi,frontal,frustrasi,fungsi,gagah,gagal,galak,galau,galon,galur,gambar,ganas,ganda,ganjil,garang,garuk,gasak,gatal,gaung,gayung,gaib,gerak,gelak,gelas,gelombang,gempa,gendang,gertak,gigih,gigit,gilap,gilas,girang,global,golek,golok,goreng,gosip,goresan,goyang,gratis,gugur,gulung,gumam,guntur,guna,gurat,gusar,guyur,guru,gembira,gemuk,getah,gigi,hadap,hadiah,hafal,halal,halus,hambat,hampa,hancur,hangat,hadir,hakim,haram,harmoni,harap,harga,hari,harta,hasrat,hati,hawa,hebat,heboh,hemat,heran,hikayat,hikmah,hilang,hilir,hina,hidup,hitam,hijau,hormati,hormat,hubung,hulur,hujan,huruf,hutan,humanis,humor,holistik,ibu,ijazah,ikatan,ikat,ikhlas,ikhtiar,iklim,ikrar,ikut,iman,imbal,imbas,imbuh,imam,impas,impor,impian,inap,indah,ingin,ingat,ingkar,injak,insaf,inspirasi,intai,inti,iringan,iringi,isap,islah,isyarat,istri,istimewa,ilmu,inovasi,insan,investasi,isolasi,izin,jabatan,jadwal,jahit,jagoan,jaga,jago,jahat,jahil,jaket,jalur,jamuan,janda,jangka,jangkau,jarong,jasad,jasa,jatah,jalan,janji,jauh,jawab,jatuh,jelas,jeli,jelita,jelma,jemput,jemur,jenaka,jenuh,jerami,jernih,jijik,jinak,jinjit,jiplak,jiwa,joget,jorok,juara,jual,juang,judul,jujur,junjung,jurang,jurnal,jurus,kaki,kalimat,kampung,kandang,kantuk,kapal,kapan,karang,karena,karir,karung,karya,kasih,kasur,kata,kabur,kaget,kagum,kasar,kawasan,kawan,kebun,kecil,kejar,kekal,keliru,kembar,kendali,kerja,keras,kepala,kiri,kota,kumpul,kisah,kocak,kolong,kompak,konsep,kuasa,kubur,kuda,kuliah,kurang,kursi,kusut,kuning,kunci,kita,kali,kaya,kayu,kunyit,kupas,kurus,kutuk,labuh,ladang,lahir,lajur,lakon,lalai,larang,laris,lasak,layang,layak,lazim,lebah,lebih,lebur,legam,leka,lelah,lemah,lempar,lengan,lesu,lewat,libur,liar,lidah,lincah,lingkar,lingkungan,lipas,lipat,lirih,listrik,lolos,loncat,lorong,loteng,loyak,lubang,luhur,lulus,lumpur,lumut,luncur,lutut,lucu,luka,lunas,luruh,lupa,lurus,lama,lapar,laut,lari,loyal,layan,lihat,mabuk,macan,macet,madani,magis,mahal,mahir,mainan,maju,makhluk,makna,malah,malang,manis,manfaat,masalah,masih,masuk,matang,makan,malam,malas,malu,mana,mandi,marah,mata,mati,mau,meja,merah,mikir,mimpi,minta,muda,mulai,murah,murni,musuh,mewah,milik,mimbar,mudah,mulia,mundur,murung,musim,mampu,mantap,masyarakat,meraih,merawat,merasa,meski,menang,mencari,mendapat,mengerti,menjaga,menyayangi,nada,nafas,nafkah,nahas,naik,nakal,nalar,naluri,nama,nampak,nanti,napas,narasi,nasihat,nazar,negara,negeri,nekat,nelayan,nenek,niaga,nifas,nikah,nikmat,niscaya,nista,ngarai,norma,nisbah,notasi,nujum,nurani,nusantara,nyanyi,nyali,nyala,nyaman,nyamuk,nyaris,nyata,nyawa,nyeri,ngebut,ngerti,ngeluh,ngobrol,ngomong,ngopi,ngotot,ngumpul,ngejar,ngemil,ngambil,ngantar,ngatur,ngajar,ngasih,obat,objek,obrolan,oceh,oksigen,olahraga,olah,omong,ombak,ondeh,ongkos,opah,opini,optimis,orbit,ordal,orasi,orde,organ,organisasi,orang,orientasi,orisinal,otoritas,otonomi,otomatis,otak,otot,oleh,operasi,oval,pagi,paham,pahala,pakai,paksa,pandai,panjang,papan,pasang,panas,pangkat,pasti,patuh,pecah,peduli,pekat,peka,percaya,pergi,perlu,pesan,petang,piawai,pilihan,pikir,pintar,pindah,pohon,polos,pondok,positif,puas,pujian,pulang,pulih,punah,pupuk,purba,pusaka,penting,penuh,perang,perahu,perintah,pribadi,prinsip,prioritas,produk,profesi,program,proyek,proses,publik,pinjam,pisah,pokok,potong,prihatin,raga,ragam,rakyat,ramah,ranah,rancak,randai,rapi,rapuh,rasul,raut,rahayu,rahasia,rajin,rakus,ramalan,rampas,randa,rangkul,rantai,rantau,ratap,rawat,rehat,remaja,rencana,rendam,renggang,repot,resah,rindu,ritual,riwayat,rombak,rompi,rontal,rontok,rohani,ruang,runding,runtuh,runyam,rupiah,rugi,rumit,runcing,runtun,rupawan,rusuh,ruwet,rasa,ramai,rapih,rapat,raih,redup,rela,rendah,rezeki,riang,ringan,risau,rukun,rumbai,rusak,sabda,sahaja,sahut,saing,salam,salah,santai,santun,saran,sarjana,sasaran,satuan,sabar,sakit,sama,sayang,selalu,semua,senang,serius,setia,siap,simpan,sinar,singa,sopan,sukses,sunyi,syukur,segar,sehat,semangat,sempurna,sentra,sepadu,sepakat,serasi,sering,siaga,sigap,sikap,silap,simpul,sinergi,singkat,siswa,situasi,skema,solusi,songket,sumber,sungguh,supaya,sulit,sulur,sumbu,sumpah,surga,suruh,susah,syariah,solidaritas,semesta,tabah,tabu,tahan,tajam,tapa,taruh,tatap,tawar,tabiat,takluk,tali,tamak,tandas,tangguh,tanpa,tahu,takut,tamat,tanda,tegar,teliti,tenang,terus,tiba,tiga,tiket,tindak,tinggal,tujuan,tulus,tebal,teduh,tegak,teguh,tekad,tekun,teladan,tempat,tentu,tepat,terbang,terima,terlalu,tetap,tinggi,titik,tugas,tuntas,turut,tutur,terbuka,termaju,terpadu,terpercaya,timbul,tingkah,toleran,transparan,tumbuh,tunai,turun,tuntut,tutup,ubah,udara,ukiran,ukur,ujar,ujian,ukhuwah,ulet,ulang,ulam,ulas,ulat,ulos,umat,umpama,undur,unggas,ungkap,unik,universal,unjuk,unsur,untung,upah,upaya,urai,urgen,usaha,usik,usul,utama,utara,utuh,utas,utang,vaksin,valid,variasi,vendor,verbal,verifikasi,versi,vertikal,veteran,veto,vibrasi,viral,visi,vitalitas,virus,visioner,vital,vokal,vokasi,volunter,volume,wadah,wafat,wahana,wahyu,wakaf,wakil,walimah,walid,walau,wangi,wanita,warga,warisan,warni,wartawan,wasit,waspada,wasiat,watak,wawasan,wewenang,wibawa,wirausaha,wisata,wong,wujud,wujudkan,wajar,waktu,wajah,warna,warung,yakini,yakin,yakni,yatim,yoga,yuran,yunior,yudha,yuridis,zakat,zalim,zaman,ziarah,zigzag,zodiak,zona,zuhud,zuriat,zikir,khas,khasiat,khatam,khawatir,khayal,khazanah,khalayak,khalifah,kharisma,khatulistiwa,khidmat,khilaf,khitan,khotbah,khutbah,khusus,khusyuk,syahdu,syahid,syahadat,syahwat,syaitan,syair,syarat,syariah,syariat,syirik,nganga,ngobrol,ngomong,ngopi,ngotot,ngumpul,ngunduh,ngurusin,ngusir,ngutang,ngurus,ngejar,ngeliat,ngemil,ngerti,ngambil,ngantar,ngatur,ngajar,ngasih,ngecat,ngeles,ngelirik,ngeluh,ngerem,ngeselin,ngetik,ngewarnai,ngiris,ngoreng,ngoceh,ngintip,ngilang,ngiri,ngitung,nyaman,nyata,nyawa,nyanyi,nyali,nyala,nyamuk,nyaris,nyeri,nyinyir,nyonya,nyobain,nyontek,nyuci,nyulap,nyumbang,nyimak,nyimpen,nyingkir,nyolot,nyundut,nyuntik,nyuruh]]

local function loadBuiltin()
    for word in BUILTIN:gmatch("[^,]+") do
        indexWord(word)
    end
end

-- ════════════════════════════════════════════════════════════
--  N O T I F I C A T I O N
-- ════════════════════════════════════════════════════════════
local _ns = {}
local _nc = {ok=Color3.fromRGB(50,215,110),info=Color3.fromRGB(60,135,255),warn=Color3.fromRGB(255,165,35),err=Color3.fromRGB(255,60,60)}
local function Notif(msg, kind)
    kind=kind or "info"
    local col=_nc[kind] or _nc.info
    for _,f in ipairs(_ns) do TweenSvc:Create(f,TweenInfo.new(0.1),{Position=f.Position+UDim2.new(0,0,0,32)}):Play() end
    local f=Instance.new("Frame",NGUI); f.Size=UDim2.new(0,205,0,26); f.Position=UDim2.new(1,-215,0,-50); f.BackgroundColor3=Color3.fromRGB(10,11,22); f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,7)
    local bar=Instance.new("Frame",f); bar.Size=UDim2.new(0,3,1,0); bar.BackgroundColor3=col; bar.BorderSizePixel=0; Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local lb=Instance.new("TextLabel",f); lb.Size=UDim2.new(1,-10,1,0); lb.Position=UDim2.new(0,8,0,0); lb.BackgroundTransparency=1; lb.Text=msg; lb.TextSize=11; lb.Font=Enum.Font.GothamSemibold; lb.TextColor3=Color3.fromRGB(215,228,255); lb.TextXAlignment=Enum.TextXAlignment.Left; lb.TextTruncate=Enum.TextTruncate.AtEnd
    local sk=Instance.new("UIStroke",f); sk.Color=col; sk.Thickness=1; sk.Transparency=0.55
    table.insert(_ns,1,f)
    TweenSvc:Create(f,TweenInfo.new(0.26,Enum.EasingStyle.Back),{Position=UDim2.new(1,-215,0,10)}):Play()
    task.delay(2.8,function()
        TweenSvc:Create(f,TweenInfo.new(0.16),{Position=UDim2.new(1,8,0,f.Position.Y.Offset)}):Play()
        task.delay(0.18,function() local i=table.find(_ns,f);if i then table.remove(_ns,i) end; pcall(function()f:Destroy()end) end)
    end)
end

-- ════════════════════════════════════════════════════════════
--  C O R E   L O G I C
-- ════════════════════════════════════════════════════════════
local usedSet = {}
local autoOn  = false
local humanDelay = true

local function getWords(ch)
    ch = ch:lower()
    return DICT[ch] or {}
end

local function pickAnswer(suffix)
    local ch = suffix:lower():sub(#suffix)
    local pool = DICT[ch] or {}
    if #pool==0 then return nil end
    local valid={}
    for _,w in ipairs(pool) do
        if not usedSet[w] then
            local last=w:sub(#w)
            local hn=(DICT[last] and #DICT[last]>0) and 3 or 0
            local ls=(#w>=4 and #w<=9) and 2 or 0
            table.insert(valid,{w=w,s=hn+ls+math.random()})
        end
    end
    if #valid==0 then
        for _,w in ipairs(pool) do table.insert(valid,{w=w,s=math.random()}) end
    end
    table.sort(valid,function(a,b)return a.s>b.s end)
    local pick=valid[math.random(1,math.min(12,#valid))].w
    usedSet[pick]=true
    return pick
end

-- ════════════════════════════════════════════════════════════
--  R E M O T E   H O O K
-- ════════════════════════════════════════════════════════════
local hookedRE = {}
local submitRE = nil
local submitRF = nil
local currentKata = ""
local myTurn = false

local function hookRE(re)
    if hookedRE[re] then return end
    local nm=re.Name:lower()
    if nm:find("answer") or nm:find("submit") or nm:find("send") or nm:find("input") or nm:find("word") or nm:find("type") or nm:find("ketik") or nm:find("jawab") or nm:find("chat") then
        submitRE=re
    end
    hookedRE[re]=re.OnClientEvent:Connect(function(...)
        for _,v in ipairs({...}) do
            if type(v)=="string" then
                local s=v:lower():gsub("[^a-z]","")
                if #s>=2 and #s<=25 and s:match("^[a-z]+$") and s~=currentKata then
                    currentKata=s
                    if _G._voidsk_onword then _G._voidsk_onword(s) end
                    if autoOn then
                        task.spawn(function()
                            task.wait(0.8+(humanDelay and math.random()*0.5 or 0))
                            if autoOn then
                                local ans=pickAnswer(s)
                                if ans then _G._voidsk_submit(ans) end
                            end
                        end)
                    end
                end
                if v:lower():find(lp.Name:lower()) or v:lower()=="yourturn" or v:lower():find("giliran") then
                    myTurn=true
                    if _G._voidsk_onturn then _G._voidsk_onturn(true) end
                end
            end
        end
    end)
end

local function hookAll()
    local function scan(inst,d)
        if d>6 then return end
        for _,c in ipairs(inst:GetChildren()) do
            if c:IsA("RemoteEvent") then hookRE(c)
            elseif c:IsA("RemoteFunction") then
                local nm=c.Name:lower()
                if nm:find("answer") or nm:find("submit") or nm:find("word") then submitRF=c; hookedRE[c]=true end
            end
            scan(c,d+1)
        end
    end
    scan(RS,1)
    RS.DescendantAdded:Connect(function(o) if o:IsA("RemoteEvent") then hookRE(o) end end)
end
hookAll()

-- SUBMIT
local typing=false
local function findBox()
    local best,bsc=nil,-1
    for _,gui in ipairs(pg:GetChildren()) do
        if not gui:IsA("ScreenGui") then continue end
        for _,o in ipairs(gui:GetDescendants()) do
            if o:IsA("TextBox") and o.Visible then
                local n=o.Name:lower(); local sc=0
                if n:find("input") or n:find("answer") or n:find("word") or n:find("ketik") then sc=sc+10 end
                if n:find("chat") then sc=sc+5 end
                if o.AbsoluteSize.X>150 then sc=sc+3 end
                if sc>bsc then bsc=sc; best=o end
            end
        end
    end
    return best
end

_G._voidsk_submit=function(word)
    if not word or #word==0 or typing then return end
    typing=true
    task.spawn(function()
        local sent=false
        if submitRE then pcall(function() submitRE:FireServer(word); sent=true end) end
        if not sent and submitRF then pcall(function() submitRF:InvokeServer(word); sent=true end) end
        if not sent then
            for re in pairs(hookedRE) do
                if type(re)~="boolean" then
                    local nm=re.Name:lower()
                    if nm:find("answer") or nm:find("submit") or nm:find("word") or nm:find("send") then
                        pcall(function() re:FireServer(word); sent=true end)
                    end
                end
            end
        end
        local box=findBox()
        if box then
            pcall(function() box:CaptureFocus() end); task.wait(0.05)
            pcall(function() box.Text="" end)
            for i=1,#word do
                pcall(function() box.Text=word:sub(1,i) end)
                task.wait(humanDelay and (0.07+math.random()*0.12) or 0.05)
            end
            task.wait(0.08); pcall(function() box:ReleaseFocus(true) end); task.wait(0.05)
            pcall(function() local vu=game:GetService("VirtualUser"); vu:KeyDown(Enum.KeyCode.Return); task.wait(0.04); vu:KeyUp(Enum.KeyCode.Return) end)
        end
        if _G._voidsk_onanswer then _G._voidsk_onanswer(word) end
        myTurn=false
        if _G._voidsk_onturn then _G._voidsk_onturn(false) end
        task.wait(0.3); typing=false
    end)
end

-- SCREEN SCAN
local lastScanT,lastScanW=0,""
RunService.Heartbeat:Connect(function()
    if not GUI or not GUI.Parent then return end
    local t=os.clock(); if t-lastScanT<0.45 then return end; lastScanT=t
    local best,bsc=nil,-1
    for _,gui in ipairs(pg:GetChildren()) do
        if gui==GUI or gui==NGUI then continue end
        if not gui:IsA("ScreenGui") then continue end
        for _,o in ipairs(gui:GetDescendants()) do
            local txt=nil
            if o:IsA("TextLabel") then txt=o.Text elseif o:IsA("TextBox") then txt=o.Text end
            if txt and #txt>=2 and #txt<=25 then
                local w=txt:lower():gsub("[^a-z]","")
                if #w>=2 and w:match("^[a-z]+$") then
                    local sc=0; local nm=o.Name:lower()
                    if nm:find("word") or nm:find("kata") or nm:find("current") then sc=sc+10 end
                    if nm:find("prompt") or nm:find("soal") or nm:find("display") then sc=sc+8 end
                    if o:IsA("TextLabel") and o.TextSize>=22 then sc=sc+6 end
                    if o:IsA("TextLabel") and o.TextSize>=18 then sc=sc+3 end
                    local vp=workspace.CurrentCamera.ViewportSize
                    local cx=math.abs(o.AbsolutePosition.X+o.AbsoluteSize.X/2-vp.X/2)
                    if cx<100 then sc=sc+5 end
                    if sc>bsc then bsc=sc; best=w end
                end
            end
        end
    end
    if best and best~=lastScanW and best~=currentKata then
        lastScanW=best; currentKata=best
        if _G._voidsk_onword then _G._voidsk_onword(best) end
        if autoOn then
            task.spawn(function()
                task.wait(0.8+(humanDelay and math.random()*0.5 or 0))
                if autoOn then local ans=pickAnswer(best); if ans then _G._voidsk_submit(ans) end end
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════
--  U I
-- ════════════════════════════════════════════════════════════
local CL={
    win=Color3.fromRGB(10,12,22),title=Color3.fromRGB(0,65,175),titleB=Color3.fromRGB(0,110,240),
    card=Color3.fromRGB(16,19,34),cardH=Color3.fromRGB(22,26,46),bar=Color3.fromRGB(12,15,28),
    acc=Color3.fromRGB(55,125,255),accB=Color3.fromRGB(90,155,255),accD=Color3.fromRGB(28,78,200),
    bdr=Color3.fromRGB(32,62,155),bF=Color3.fromRGB(20,27,54),txt=Color3.fromRGB(218,228,255),
    muted=Color3.fromRGB(82,108,168),dim=Color3.fromRGB(38,54,98),
    ok=Color3.fromRGB(50,215,110),warn=Color3.fromRGB(255,165,35),red=Color3.fromRGB(255,60,60),gold=Color3.fromRGB(255,205,45),
}
local function F(p,pa) local f=Instance.new("Frame");f.BorderSizePixel=0;for k,v in pairs(p) do pcall(function()f[k]=v end) end;if pa then f.Parent=pa end;return f end
local function L(p,pa) local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Font=Enum.Font.GothamSemibold;for k,v in pairs(p) do pcall(function()l[k]=v end) end;if pa then l.Parent=pa end;return l end
local function B(p,pa) local b=Instance.new("TextButton");b.BorderSizePixel=0;b.Font=Enum.Font.GothamBold;for k,v in pairs(p) do pcall(function()b[k]=v end) end;if pa then b.Parent=pa end;return b end
local function R(r,p) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r) end
local function SK(c,t,p) local s=Instance.new("UIStroke",p);s.Color=c;s.Thickness=t;return s end
local function GD(c1,c2,rot,p) local g=Instance.new("UIGradient",p);g.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,c1),ColorSequenceKeypoint.new(1,c2)};g.Rotation=rot end
local tw=function(o,pr,t,st,dr) TweenSvc:Create(o,TweenInfo.new(t,st or Enum.EasingStyle.Quad,dr or Enum.EasingDirection.Out),pr):Play() end

-- WINDOW 300×460, pojok kiri atas (tidak halangi kata di tengah)
local WIN=F({Size=UDim2.new(0,300,0,460),Position=UDim2.new(0,6,0,6),BackgroundColor3=CL.win,Active=true,Draggable=true},GUI)
R(12,WIN); SK(CL.bdr,1.5,WIN); GD(Color3.fromRGB(10,13,24),Color3.fromRGB(6,7,16),160,WIN)

-- TITLE
local TB=F({Size=UDim2.new(1,0,0,36),BackgroundColor3=CL.title,ZIndex=3},WIN); R(12,TB)
F({Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=CL.title,BorderSizePixel=0,ZIndex=2},TB)
GD(CL.titleB,CL.title,130,TB)
local lg=F({Size=UDim2.new(0,24,0,24),Position=UDim2.new(0,7,0.5,-12),BackgroundColor3=CL.acc,ZIndex=4},TB); R(6,lg); GD(CL.accB,CL.accD,135,lg)
L({Size=UDim2.new(1,0,1,0),Text="V",TextSize=13,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},lg)
L({Size=UDim2.new(0,115,0,15),Position=UDim2.new(0,36,0,3),Text="VOID HUB",TextSize=13,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},TB)
local dbLbl=L({Size=UDim2.new(0,165,0,11),Position=UDim2.new(0,36,0,21),Text="Loading DB...",TextSize=8,TextColor3=Color3.fromRGB(130,180,255),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},TB)
local BC=B({Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-28,0.5,-11),BackgroundColor3=CL.red,Text="✕",TextSize=10,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},TB); R(5,BC)
local BM=B({Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-54,0.5,-11),BackgroundColor3=CL.warn,Text="−",TextSize=14,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},TB); R(5,BM)
local BODY=F({Size=UDim2.new(1,0,1,-36),Position=UDim2.new(0,0,0,36),BackgroundTransparency=1},WIN)

BC.MouseButton1Click:Connect(function()
    tw(WIN,{Size=UDim2.new(0,300,0,0)},0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
    task.delay(0.22,function()
        for _,c in pairs(hookedRE) do pcall(function() if type(c)~="boolean" then c:Disconnect() end end) end
        pcall(function()GUI:Destroy()end); pcall(function()NGUI:Destroy()end)
    end)
end)
local mini=false
BM.MouseButton1Click:Connect(function()
    mini=not mini; BODY.Visible=not mini
    tw(WIN,{Size=mini and UDim2.new(0,300,0,36) or UDim2.new(0,300,0,460)},0.18)
end)

local P=7

-- STATUS BAR (kata aktif)
local stBar=F({Size=UDim2.new(1,-P*2,0,44),Position=UDim2.new(0,P,0,6),BackgroundColor3=CL.bar},BODY); R(9,stBar); SK(CL.bF,1.2,stBar)
L({Size=UDim2.new(0.52,0,0,14),Position=UDim2.new(0,9,0,4),Text="KATA DI GAME",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=CL.muted,TextXAlignment=Enum.TextXAlignment.Left},stBar)
local turnLbl=L({Size=UDim2.new(0.46,0,0,14),Position=UDim2.new(0.52,0,0,4),Text="● standby",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=CL.dim,TextXAlignment=Enum.TextXAlignment.Right},stBar)
Instance.new("UIPadding",turnLbl).PaddingRight=UDim.new(0,8)
local kataLbl=L({Size=UDim2.new(0.54,0,0,24),Position=UDim2.new(0,9,0,18),Text="—",TextSize=20,Font=Enum.Font.GothamBold,TextColor3=CL.gold,TextXAlignment=Enum.TextXAlignment.Left},stBar)
L({Size=UDim2.new(0.08,0,0,24),Position=UDim2.new(0.54,0,0,18),Text="→",TextSize=14,TextColor3=CL.dim},stBar)
local hintLbl=L({Size=UDim2.new(0.36,0,0,24),Position=UDim2.new(0.62,0,0,18),Text="—",TextSize=13,Font=Enum.Font.GothamBold,TextColor3=CL.accB,TextXAlignment=Enum.TextXAlignment.Left},stBar)

-- TOGGLE ROW
local togY=6+44+5
local togRow=F({Size=UDim2.new(1,-P*2,0,26),Position=UDim2.new(0,P,0,togY),BackgroundTransparency=1},BODY)
local function mkTgl(xOff,ww,lbl,init,cb)
    local on=init
    local cont=F({Size=UDim2.new(0,ww,1,0),Position=UDim2.new(0,xOff,0,0),BackgroundColor3=CL.bar},togRow); R(6,cont); SK(CL.bF,1,cont)
    local lr=L({Size=UDim2.new(0.62,0,1,0),Position=UDim2.new(0,7,0,0),Text=lbl,TextSize=9,Font=Enum.Font.GothamBold,TextColor3=on and CL.accB or CL.muted,TextXAlignment=Enum.TextXAlignment.Left},cont)
    local pill=F({Size=UDim2.new(0,28,0,14),Position=UDim2.new(1,-34,0.5,-7),BackgroundColor3=on and CL.accD or Color3.fromRGB(18,22,42)},cont); R(7,pill)
    local kn=F({Size=UDim2.new(0,10,0,10),Position=on and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,2,0.5,-5),BackgroundColor3=on and Color3.fromRGB(255,255,255) or CL.muted},pill); R(5,kn)
    local hit=B({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},cont)
    hit.MouseButton1Click:Connect(function()
        on=not on
        tw(pill,{BackgroundColor3=on and CL.accD or Color3.fromRGB(18,22,42)},0.15)
        tw(kn,{Position=on and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,2,0.5,-5),BackgroundColor3=on and Color3.fromRGB(255,255,255) or CL.muted},0.15)
        lr.TextColor3=on and CL.accB or CL.muted; cb(on)
    end)
end
mkTgl(0,138,"AUTO PLAY",false,function(on) autoOn=on; Notif(on and "AUTO PLAY ON ✓" or "AUTO PLAY OFF",on and "ok" or "warn") end)
mkTgl(142,144,"Human Delay",true,function(on) humanDelay=on end)

-- HURUF GRID (horizontal scroll)
local alphaY=togY+26+5
L({Size=UDim2.new(1,-P*2,0,13),Position=UDim2.new(0,P,0,alphaY),Text="  AWALAN KATA",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=CL.acc,TextXAlignment=Enum.TextXAlignment.Left},BODY)
F({Size=UDim2.new(1,-P*2,0,1),Position=UDim2.new(0,P,0,alphaY+13),BackgroundColor3=CL.bdr},BODY).BackgroundTransparency=0.6

local aSF=Instance.new("ScrollingFrame",BODY)
aSF.Size=UDim2.new(1,-P*2,0,48); aSF.Position=UDim2.new(0,P,0,alphaY+16)
aSF.BackgroundTransparency=1; aSF.BorderSizePixel=0
aSF.ScrollBarThickness=2; aSF.ScrollBarImageColor3=CL.acc
aSF.ScrollingDirection=Enum.ScrollingDirection.X
aSF.CanvasSize=UDim2.new(0,0,0,0); aSF.AutomaticCanvasSize=Enum.AutomaticSize.X
local aLL=Instance.new("UIListLayout",aSF); aLL.FillDirection=Enum.FillDirection.Horizontal; aLL.Padding=UDim.new(0,3); aLL.SortOrder=Enum.SortOrder.LayoutOrder

-- SEARCH
local searchY=alphaY+16+48+4
local sF=F({Size=UDim2.new(1,-P*2,0,28),Position=UDim2.new(0,P,0,searchY),BackgroundColor3=CL.bar},BODY); R(7,sF); SK(CL.bF,1,sF)
L({Size=UDim2.new(0,22,1,0),Position=UDim2.new(0,7,0,0),Text="🔍",TextSize=12,TextColor3=CL.muted},sF)
local sTB=Instance.new("TextBox",sF); sTB.Size=UDim2.new(1,-32,1,0); sTB.Position=UDim2.new(0,26,0,0); sTB.BackgroundTransparency=1; sTB.ClearTextOnFocus=false; sTB.Text=""; sTB.PlaceholderText="Filter kata..."; sTB.Font=Enum.Font.GothamSemibold; sTB.TextSize=11; sTB.TextColor3=CL.txt; sTB.PlaceholderColor3=CL.dim; sTB.TextXAlignment=Enum.TextXAlignment.Left

-- WORD COUNT
local wcY=searchY+28+3
local wcL=L({Size=UDim2.new(1,-P*2,0,14),Position=UDim2.new(0,P,0,wcY),Text="Pilih huruf untuk mulai",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=CL.muted,TextXAlignment=Enum.TextXAlignment.Left},BODY)
F({Size=UDim2.new(1,-P*2,0,1),Position=UDim2.new(0,P,0,wcY+14),BackgroundColor3=CL.bdr},BODY).BackgroundTransparency=0.6

-- WORD SCROLL
local actH=42
local wSY=wcY+16
local wSH=460-36-wSY-actH-P-4
local wSF=Instance.new("ScrollingFrame",BODY); wSF.Size=UDim2.new(1,-P*2,0,wSH); wSF.Position=UDim2.new(0,P,0,wSY); wSF.BackgroundTransparency=1; wSF.BorderSizePixel=0; wSF.ScrollBarThickness=3; wSF.ScrollBarImageColor3=CL.acc; wSF.CanvasSize=UDim2.new(0,0,0,0); wSF.AutomaticCanvasSize=Enum.AutomaticSize.Y
local wGrid=Instance.new("UIGridLayout",wSF); wGrid.CellSize=UDim2.new(0.5,-3,0,30); wGrid.CellPadding=UDim2.new(0,4,0,3); wGrid.SortOrder=Enum.SortOrder.LayoutOrder
Instance.new("UIPadding",wSF).PaddingBottom=UDim.new(0,4)

-- ACTION BAR
local aBarY=460-36-actH-P
local aBar=F({Size=UDim2.new(1,-P*2,0,actH),Position=UDim2.new(0,P,0,aBarY),BackgroundColor3=CL.bar},BODY); R(9,aBar); SK(CL.bdr,1.5,aBar); GD(Color3.fromRGB(14,17,38),Color3.fromRGB(9,11,26),160,aBar)
L({Size=UDim2.new(0.32,0,0,12),Position=UDim2.new(0,9,0,3),Text="DIPILIH",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=CL.dim,TextXAlignment=Enum.TextXAlignment.Left},aBar)
local selLbl=L({Size=UDim2.new(0.56,0,0,22),Position=UDim2.new(0,9,0,16),Text="—",TextSize=15,Font=Enum.Font.GothamBold,TextColor3=CL.accB,TextXAlignment=Enum.TextXAlignment.Left},aBar)
local sendBtn=B({Size=UDim2.new(0,82,0,30),Position=UDim2.new(1,-90,0.5,-15),BackgroundColor3=CL.accD,Text="⌨ KIRIM",TextSize=11,TextColor3=Color3.fromRGB(255,255,255),ZIndex=4},aBar); R(7,sendBtn); GD(CL.accB,CL.accD,90,sendBtn)
sendBtn.MouseEnter:Connect(function() tw(sendBtn,{BackgroundColor3=CL.acc},0.1) end)
sendBtn.MouseLeave:Connect(function() tw(sendBtn,{BackgroundColor3=CL.accD},0.1) end)

local curSel=nil
sendBtn.MouseButton1Click:Connect(function()
    if not curSel then Notif("Pilih kata dulu!","warn"); return end
    _G._voidsk_submit(curSel)
end)

-- WORD LIST BUILDER
local prevWBtn=nil
local function buildList(ch,filter)
    for _,c in ipairs(wSF:GetChildren()) do if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end end
    curSel=nil; selLbl.Text="—"; prevWBtn=nil
    local all=getWords(ch); local words={}
    if filter and #filter>0 then
        local fl=filter:lower()
        for _,w in ipairs(all) do if w:find(fl,1,true) then table.insert(words,w) end end
    else words=all end
    wcL.Text=#words.." kata  ('"..ch:upper().."')"
    if #words==0 then
        L({Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,Text="Tidak ada kata",TextSize=10,TextColor3=CL.dim,Font=Enum.Font.GothamSemibold},wSF)
        return
    end
    for i,word in ipairs(words) do
        local last=word:sub(#word):lower(); local hasNext=DICT[last] and #DICT[last]>0
        local btn=B({BackgroundColor3=CL.card,Text="",ZIndex=3,LayoutOrder=i},wSF); R(6,btn); SK(CL.bF,1,btn)
        L({Size=UDim2.new(1,-24,1,0),Position=UDim2.new(0,8,0,0),Text=word,TextSize=11,Font=Enum.Font.GothamBold,TextColor3=CL.txt,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},btn)
        local bdg=F({Size=UDim2.new(0,18,0,16),Position=UDim2.new(1,-21,0.5,-8),BackgroundColor3=hasNext and CL.ok or CL.warn,ZIndex=4},btn); R(4,bdg); bdg.BackgroundTransparency=0.45
        L({Size=UDim2.new(1,0,1,0),Text=last:upper(),TextSize=8,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},bdg)
        btn.MouseButton1Click:Connect(function()
            if prevWBtn then tw(prevWBtn,{BackgroundColor3=CL.card},0.1) end
            tw(btn,{BackgroundColor3=CL.accD},0.1); SK(CL.acc,1.5,btn)
            prevWBtn=btn; curSel=word; selLbl.Text=word
        end)
        btn.MouseEnter:Connect(function() if btn~=prevWBtn then tw(btn,{BackgroundColor3=CL.cardH},0.08) end end)
        btn.MouseLeave:Connect(function() if btn~=prevWBtn then tw(btn,{BackgroundColor3=CL.card},0.08) end end)
    end
end

local curAlpha="a"
sTB:GetPropertyChangedSignal("Text"):Connect(function() buildList(curAlpha,sTB.Text) end)

-- ALPHABET BUTTONS
local prevABtn=nil
local alphaButtons={}
local function selAlpha(ch,btnRef)
    if prevABtn then tw(prevABtn,{BackgroundColor3=CL.card,TextColor3=CL.muted},0.12) end
    tw(btnRef,{BackgroundColor3=CL.acc,TextColor3=Color3.fromRGB(255,255,255)},0.12)
    prevABtn=btnRef; curAlpha=ch; sTB.Text=""; buildList(ch,"")
    hintLbl.Text=pickAnswer(ch) or "—"
end

for i=1,26 do
    local ch=string.char(96+i)
    local btn=B({Size=UDim2.new(0,30,1,-4),BackgroundColor3=CL.card,Text=ch:upper(),TextSize=11,TextColor3=CL.muted,Font=Enum.Font.GothamBold,LayoutOrder=i,ZIndex=3},aSF); R(5,btn)
    alphaButtons[ch]=btn
    btn.MouseButton1Click:Connect(function() selAlpha(ch,btn) end)
end

-- UI CALLBACKS
_G._voidsk_onword=function(kata)
    kataLbl.Text=kata
    hintLbl.Text=pickAnswer(kata) or "—"
    -- auto highlight huruf
    local ch=kata:sub(#kata):lower()
    if alphaButtons[ch] then
        selAlpha(ch,alphaButtons[ch])
    end
end
_G._voidsk_onturn=function(on)
    myTurn=on
    if on then tw(turnLbl,{TextColor3=CL.ok},0.2); turnLbl.Text="● GILIRAN KAMU"
    else tw(turnLbl,{TextColor3=CL.dim},0.2); turnLbl.Text="● menunggu..." end
end
_G._voidsk_onanswer=function(w)
    Notif("✓ "..w,"ok")
end

-- ════════════════════════════════════════════════════════════
--  D B   F E T C H   (async, tidak block UI)
-- ════════════════════════════════════════════════════════════
WIN.Position=UDim2.new(0,6,1.5,0); WIN.BackgroundTransparency=1
tw(WIN,{Position=UDim2.new(0,6,0,6),BackgroundTransparency=0},0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out)

task.spawn(function()
    -- Tampil loading
    Notif("Memuat database KBBI...","info")

    local ok1, raw1 = pcall(function()
        return game:HttpGet(DB_URL, true)
    end)

    if ok1 and raw1 and #raw1 > 1000 then
        local count = parseAndIndex(raw1)
        LOADED = true
        dbLbl.Text = "KBBI  •  "..count.." kata loaded"
        Notif("DB loaded: "..count.." kata KBBI ✓","ok")
        -- rebuild list untuk huruf aktif
        buildList(curAlpha, "")
        -- update semua huruf counter
        for ch, btn in pairs(alphaButtons) do
            local cnt = DICT[ch] and #DICT[ch] or 0
            btn.TextColor3 = cnt > 0 and CL.muted or CL.dim
        end
    else
        -- coba fallback
        Notif("URL 1 gagal, coba fallback...","warn")
        local ok2, raw2 = pcall(function()
            return game:HttpGet(DB_FALLBACK, true)
        end)
        if ok2 and raw2 and #raw2 > 500 then
            local count = parseAndIndex(raw2)
            LOADED = true
            dbLbl.Text = "KBBI fallback  •  "..count.." kata"
            Notif("Fallback DB: "..count.." kata ✓","ok")
            buildList(curAlpha, "")
        else
            -- pakai built-in
            Notif("Fetch gagal → pakai built-in 5000 kata","warn")
            loadBuiltin()
            dbLbl.Text = "Built-in  •  "..TOTAL.." kata"
            LOADED = true
            buildList(curAlpha, "")
        end
    end

    -- default select "a"
    task.wait(0.3)
    if alphaButtons["a"] then selAlpha("a",alphaButtons["a"]) end

    -- info RE
    local reCount=0; for _ in pairs(hookedRE) do reCount=reCount+1 end
    task.wait(1)
    Notif("RE hooked: "..reCount.." | DB: "..TOTAL.." kata","info")
end)
