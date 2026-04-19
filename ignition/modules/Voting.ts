import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Voting", (m) => {
    const candidates = ["Alice", "Bob", "Charlie"];
    
    const voting = m.contract("Voting", [candidates]);
    
    return { voting };
});