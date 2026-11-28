import Testing

@testable import CloudCore

@Suite struct AddressFormattingTests {
    @Test(arguments: [
        ("南京市 秦淮区 夫子庙街道", "平江府路34号"),
        ("南京市 秦淮区 新街口街道", "夫子庙街道平江府路34号"),
        ("南京市 秦虹区 夫子庙街道", "秦淮区夫子庙街道平江府路34号"),
        ("南京市 秦淮区 夫子庙镇", "夫子庙街道平江府路34号"),
        ("南昌市 秦淮区 夫子庙街道", "南京市秦淮区夫子庙街道平江府路34号"),
        ("南京市秦淮区夫子庙街道", "平江府路34号"),
        (" 南京市\u{3000}秦淮区  夫子庙街道 ", "平江府路34号"),
    ])
    func removesOnlyMatchingPrefix(city: String, expected: String) {
        #expect(AddressFormatting.detailedAddressRemainder(
            country: "中国",
            state: "江苏省",
            city: city,
            formattedAddress: "中国江苏省南京市秦淮区夫子庙街道平江府路34号"
        ) == expected)
    }

    @Test func keepsARepeatedPlaceNameInTheStreetBody() {
        #expect(AddressFormatting.detailedAddressRemainder(
            country: "中国",
            state: "湖北省",
            city: "武汉市",
            formattedAddress: "中国湖北省武汉市武汉大道夫子庙路"
        ) == "武汉大道夫子庙路")
    }

    @Test func emptyAddressFallsBackToEmpty() {
        #expect(AddressFormatting.detailedAddressRemainder(
            country: "中国", state: "湖北省", city: "武汉市", formattedAddress: "  "
        ).isEmpty)
    }
}
