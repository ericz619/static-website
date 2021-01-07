/* eslint-disable no-undef */
const chai = require("chai");
const chaiHttp = require("chai-http");
const server = require("../index");

chai.should();
chai.use(chaiHttp);

process.env.NODE_ENV = "test";

describe("Starting Server", () => {
  describe("/ GET", () => {
    it("should return status 200", (done) => {
      chai
        .request(server)
        .get("/")
        .end((req, res) => {
          res.should.have.status(200);
          done();
        });
    });
  });
});
