function Optimize-SSD() {
    # SSD life improvement
    fsutil behavior set DisableLastAccess 1
    fsutil behavior set EncryptPagingFile 0
}

Optimize-SSD
