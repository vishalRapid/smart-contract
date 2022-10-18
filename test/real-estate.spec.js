const { expect } = require("chai");

let Token;
let hardhatToken;
let owner;
let addr1;
describe("Real estate contract", function () {
  beforeEach(async () => {
    [owner, addr1] = await ethers.getSigners();

    Token = await ethers.getContractFactory("RealEstate");

    hardhatToken = await Token.deploy();
  });

  it("Deployment should initialize the property count to 0", async () => {
    expect(await hardhatToken.propertiesCount()).to.equal(0);
  });

  it("Should update the property count when new property is added", async () => {
    await hardhatToken.addProperty("GOOD PROPERTY", "US", 12000, 1, true);
    expect(await hardhatToken.propertiesCount()).to.equal(1);
  });

  it("Should change the onSale property of the contract", async () => {
    await hardhatToken.addProperty("GOOD PROPERTY", "US", 12000, 1, true);
    await hardhatToken.changeOnSale(false, 0);
    let property = await hardhatToken.totalProperties(0);
    expect(property.onSale).to.equal(false);
  });

  it("Should through error when trying to buy property not on sale", async () => {
    await hardhatToken.addProperty("GOOD PROPERTY", "US", 12000, 1, true);
    await hardhatToken.changeOnSale(false, 0);
    try {
      await hardhatToken.connect(addr1).buyProperty(0);
    } catch (err) {
      expect(err.message).to.include("Property not on sale");
    }
  });
});
