import hre from "hardhat";

console.log("HRE keys:", Object.keys(hre));
const net = (hre as any).network;
console.log("network type:", typeof net);
console.log("network keys:", Object.keys(net));
const conn = await net.connect();
console.log("connection keys:", Object.keys(conn));