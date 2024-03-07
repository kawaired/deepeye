using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Profiling;

public class MyDynamic : MonoBehaviour
{
    [Range(0,1)]
    public float stiffness=0.1f;
    [Range(0,1)]
    public float damping=0.1f;
    [Range(0,10)]
    public float elasticity=3;
    [Range(0,1)]
    public float fasten=0;
    [Range(0,1)]
    public float collideradius=0;
    [Range(0,1)]
    public float pullmax=0;
    [Range(0,50)]
    public float centrifugalforce=0;

    public enum FreezeAxis
    {
        None, X, Y, Z
    }

    public enum  GroupLockType
    {
        None,RowLock,CircleLock
    }
	
    public FreezeAxis freezeaxis = FreezeAxis.None;
    public GroupLockType locktype= GroupLockType.None;
    public Vector3 mulstrength=new Vector3(0,0,0);
    public Vector3 force=new Vector3(0,0,0);    
    public Vector3 endoffset;
    public List<Transform> boneroots;
    public List<MyCollider> colliderlist=new List<MyCollider>();

    public class Bone 
    {
        public Transform tf;
        public int parentindex;
        public float len;
        public Vector3 preposition;
        public Vector3 curposition;
        public Vector3 initlocalpos;
        public Vector3 initworldpos;
        public Vector3 preinitpos;
        public Vector3 movement;
        public Quaternion initlocalrot;
    }

    class WholeBone
    {
        public Transform root;
        public List<Bone> bonelist;
        public Vector3 preposition;
        public Vector3 localmulstrength;
        public Vector3 resetmulstrength;
        public Quaternion prequaternion;
        public Quaternion curquaternion;
        public Vector3 rotaxi;
    }

    private List<WholeBone> VerticalBones=new List<WholeBone>();
    private List<List<Bone>> HorizontalBones=new List<List<Bone>>();

    //1和2的步骤只会进行一次
    void Start()
    {
        //1，遍历所有的树子节点
        foreach(Transform boneroot in boneroots)
        {
            WholeBone wb=new WholeBone();
            ReadwholeBone(wb,boneroot);
            VerticalBones.Add(wb);
        }
        //2，记录初始化的local位置和local
        foreach(WholeBone wb in VerticalBones)
        {
            InitLocalTrans(wb);
        }
    }

    //从步骤3开始后面的步骤每帧都会执行
    void Update()
    {
        //3,每一帧都会先重置到初始位置
        foreach(WholeBone wb in VerticalBones)
        {
            wb.prequaternion=wb.curquaternion;
            wb.curquaternion=wb.root.rotation;
            ResetTrans(wb);
        }        

        //4，绘制出会与动态骨骼发生碰撞的碰撞体
        foreach(MyCollider collider in colliderlist)
        {
            collider.DrawCollider();
        }
    }

    // Update后每帧执行
    void LateUpdate()
    { 
        foreach(WholeBone wb in VerticalBones)
        {
            //5，计算出每一个骨骼节由于根节点的移动或旋转导致的得初始位置的变化
            CheckMovement(wb);
            //6，计算出整个骨骼树从父节点到子节点方向的位置
            CalculateVerticalMovement(wb);
        }

        foreach(List<Bone> bonelist in HorizontalBones)
        {
            if(bonelist.Count>1){
                //6，计算骨骼横向相互作用的拉力
                CalculateHorizontalMovement(bonelist);
            }
        }

        foreach(WholeBone wb in VerticalBones)
        {
            //7，计算碰撞与某一个方向的位移锁
            CheckCollideAndLock(wb);
            //8,将计算后的位置赋值到各个节点的transfrom上
            MoveBone(wb);
        }
    }

    private void ReadwholeBone(WholeBone wb,Transform brtf)
    {
        if(brtf!=null)
        { 
            wb.bonelist=new List<Bone>();
            wb.root=brtf;
            wb.preposition=wb.root.position;
            wb.localmulstrength=wb.root.worldToLocalMatrix.MultiplyVector(mulstrength);
            wb.resetmulstrength=mulstrength;
            wb.prequaternion=wb.root.rotation;
            wb.curquaternion=wb.root.rotation;
            wb.rotaxi=new Vector3(0,1,0);
            TraversalBone(wb,brtf,-1,0);
        }
    }

    private void InitLocalTrans(WholeBone wb)
    {
        foreach(Bone b in wb.bonelist)
        {
            if(b.tf!=null)
            {
                b.initlocalpos=b.tf.localPosition;
                b.initlocalrot=b.tf.localRotation;
                b.initworldpos=b.tf.position;
            }
            else
            {
                b.initlocalpos=endoffset;
                b.initlocalrot=Quaternion.identity;
            }
        }
    }
    
    private void TraversalBone(WholeBone wb,Transform btf,int parentidx,int levelidx)
    {
        Bone b=new Bone();
        b.tf=btf;
        b.parentindex=parentidx;
        if(btf!=null)
        {
            if(parentidx<0)
            {
                b.len=0;
            }
            else
            {
                b.len=(btf.localPosition).magnitude;
            }
            b.preinitpos=b.preposition=b.curposition=b.tf.position;

            int index=wb.bonelist.Count;
            wb.bonelist.Add(b);

            if(HorizontalBones.Count==levelidx)
            {
                HorizontalBones.Add(new List<Bone>());
            }

            if(HorizontalBones.Count>levelidx)
            {
                 HorizontalBones[levelidx].Add(b);
            }
            
            levelidx=levelidx+1;
            
            if(b.tf.childCount>0)
            {
                for(int i=0;i<b.tf.childCount;i++)
                {
                    TraversalBone(wb,b.tf.GetChild(i),index,levelidx);
                }
            }
            else if(endoffset.magnitude>0)
            {
                TraversalBone(wb,null,index,levelidx);
            }
        }
        else
        {
            b.len=endoffset.magnitude;
            wb.bonelist.Add(b);
        }
    }

    private void ResetTrans(WholeBone wb)
    {
        foreach(Bone b in wb.bonelist)
        {
            if(b.tf!=null)
            {
                b.tf.localPosition=b.initlocalpos;
                b.tf.localRotation=b.initlocalrot;
            }
        }
    }

    
    private void CheckMovement(WholeBone wholebone)
    {
        foreach(Bone b in wholebone.bonelist)
        {
            if(b.tf!=null)
            {
                b.movement=b.tf.position-b.preinitpos;
                b.preinitpos=b.tf.position;
            }
        }
    }

    private void GetRotateAxi(WholeBone wb)
    {
        Quaternion change=ChangedQuaternion(wb.prequaternion,wb.curquaternion);
        if(Mathf.Abs(change.w-1)>0.0001)
        {
            float axifac=Mathf.Sin(Mathf.Acos(change.w));
            wb.rotaxi=wb.root.localToWorldMatrix.MultiplyVector((new Vector3(change.x/axifac,change.y/axifac,change.z/axifac)).normalized);
        }  
    }

    private Quaternion ChangedQuaternion(Quaternion origin, Quaternion aim)
    {
        return Quaternion.Inverse(origin)*aim;
    }

     //计算投影向量
    public Vector3 ComputeHorizontal(Vector3 projectvector,Vector3 aimvector)
    {
        Vector3 normalhorizontal=projectvector.normalized;
        return Vector3.Dot(aimvector,normalhorizontal)*normalhorizontal;
    }

    //计算向量到投影向量的垂直向量
    public Vector3 ComputeVertical(Vector3 projectvector,Vector3 aimvector)
    {
        Vector3 normalhorizontal=projectvector.normalized;
        return (aimvector-Vector3.Dot(aimvector,normalhorizontal)*normalhorizontal);
    }

     private void CalculateVerticalMovement(WholeBone wholebone)
    {
        Bone startbone=wholebone.bonelist[0];
        startbone.preposition=startbone.curposition;
        startbone.curposition=startbone.tf.position;
        Transform startp=startbone.tf.parent;
        Vector3 centrifugal=Vector3.zero;

        //计算出离心力的方向
        if(startp!=null)
        {
            Vector3 linevector=startbone.tf.position;
            linevector=(startbone.tf.position-startp.position).normalized;
            GetRotateAxi(wholebone);
            centrifugal=ComputeVertical(wholebone.rotaxi,linevector);
        }

        //计算出每帧造成位移
        ComputeStrength(wholebone,centrifugal);
        //保持原形态的计算
        KeepShape(wholebone);
        
    }

    private void CalculateHorizontalMovement(List<Bone> bonelist)
    {
        float halfindex=(bonelist.Count-1)/2.0f;
        int preboneidx=(int)Mathf.Floor(halfindex);
        int nextboneidx=(int)Mathf.Ceil(halfindex);
        Bone prebone=bonelist[preboneidx];
        Bone nextbone=bonelist[nextboneidx];
        Bone preboneroot=null;
        Bone nextboneroot=null;
    
        if(bonelist.Count%2==0)
        {

            float dis=(prebone.curposition-nextbone.curposition).magnitude;
            float initdis=(prebone.initworldpos-nextbone.initworldpos).magnitude;
            if(dis>initdis)
            {
                float movefac=(dis-initdis)/(2*initdis);
                prebone.curposition=prebone.curposition+(nextbone.curposition-prebone.curposition)*movefac;
                nextbone.curposition=nextbone.curposition+(prebone.curposition-nextbone.curposition)*movefac;
            }
        }

        for(int i=1;i<=preboneidx;i++)
        {
            preboneroot=bonelist[preboneidx-i+1];
            prebone=bonelist[preboneidx-i];
            HorizontalVectorKeep(prebone,preboneroot);
            
            nextboneroot=bonelist[nextboneidx+i-1];
            nextbone=bonelist[nextboneidx+i];
            HorizontalVectorKeep(nextbone,nextboneroot);
        }
    }

    private void HorizontalVectorKeep(Bone originbone,Bone aimbone)
    {
        float dis=(originbone.curposition-aimbone.curposition).magnitude;
        float initdis=(originbone.initworldpos-aimbone.initworldpos).magnitude*(1+pullmax);
        if(dis>initdis)
        {
            originbone.curposition=originbone.curposition+(aimbone.curposition-originbone.curposition)*((dis-initdis)/(initdis));
        }
    }

    private void ComputeStrength(WholeBone wholebone,Vector3 centrifugal)
    {
        //更具向量计算出给定的力的向量
        wholebone.resetmulstrength=Mathf.Max(Vector3.Dot(wholebone.root.localToWorldMatrix.MultiplyVector(wholebone.localmulstrength),mulstrength.normalized),0)*mulstrength.normalized;
        Vector3 mergestrength=(mulstrength-wholebone.resetmulstrength+force)*Time.deltaTime;
        for(int i=1;i<wholebone.bonelist.Count;i++)
        {
            Bone b=wholebone.bonelist[i];
            Vector3 v=b.curposition-b.preposition;
            Vector3 rmove=b.movement*stiffness;
            b.preposition=b.curposition+rmove;  
            b.curposition=b.curposition+rmove+v*(1-damping)+mergestrength+centrifugal*v.magnitude*centrifugalforce*Time.deltaTime;  
        }
    }

    private void KeepShape(WholeBone wholebone)
    {
        for(int i=1;i<wholebone.bonelist.Count;i++)
        {
            Bone b=wholebone.bonelist[i];
            Bone pb=wholebone.bonelist[b.parentindex];
            float restlen=b.initlocalpos.magnitude;
            Matrix4x4 mp=pb.tf.localToWorldMatrix;
            mp.SetColumn(3,pb.curposition);
            Vector3 resetpos=mp.MultiplyPoint3x4(b.initlocalpos);
            Vector3 d=resetpos-b.curposition;
            b.curposition+=d*elasticity*Time.deltaTime;//向最初始位置尝试还原

             d = resetpos - b.curposition;
            float len = d.magnitude;
            float maxlen = restlen * (1 - fasten) * 2;
            if (len > maxlen)
            {
                b.curposition += d * ((len - maxlen) / len);
            }
            KeepBoneLength(b,pb);
        }
    }

    private void CheckCollideAndLock(WholeBone wholebone)
    {
        for(int i=1;i<wholebone.bonelist.Count;i++)
        {
            Bone b=wholebone.bonelist[i];
            Bone pb=wholebone.bonelist[b.parentindex];
            KeepBoneLength(b,pb);
            foreach(MyCollider collider in colliderlist)
            {
                collider.CheckCollide(ref b.curposition,collideradius);
            }

            if (freezeaxis != FreezeAxis.None)
            {
                Plane movePlane = new Plane();
                Vector3 planeNormal = pb.tf.localToWorldMatrix.GetColumn((int)freezeaxis - 1).normalized;
                movePlane.SetNormalAndPosition(planeNormal, pb.curposition);
                b.curposition -= movePlane.normal * movePlane.GetDistanceToPoint(b.curposition);
            }
        }
    }

    private void KeepBoneLength(Bone b,Bone pb)
    {
        Vector3 dd=b.curposition-pb.curposition;
        float restlen=b.initlocalpos.magnitude;
        float leng=dd.magnitude;
        if(leng>(1+pullmax)*restlen)
        {
            b.curposition=b.curposition-dd*((leng-restlen*(1+pullmax))/leng);
        }
        else if(leng<(1-pullmax)*restlen)
        {
            b.curposition=b.curposition-dd*((leng-restlen*(1-pullmax))/leng);
        }
    }

    private void MoveBone(WholeBone wholebone)
    {
        for(int i=1;i<wholebone.bonelist.Count;i++)
        {
            Bone b=wholebone.bonelist[i];
            Bone pb=wholebone.bonelist[b.parentindex];
          
            Vector3 dd=b.curposition-pb.curposition;
            Vector3 v0=pb.tf.TransformDirection(b.initlocalpos);
            Quaternion rot = Quaternion.FromToRotation(v0, dd);
            pb.tf.rotation = rot * pb.tf.rotation;
            
            
            if(b.tf!=null)
            {
                b.tf.position=b.curposition;
            } 
        }
    }

    void OnDrawGizmos()
    {
        Gizmos.color=Color.yellow; 
        foreach(WholeBone wb in VerticalBones)
        {
            Gizmos.DrawLine(wb.root.position,wb.root.position+wb.rotaxi);
            Debug.Log(wb.rotaxi);
            foreach(Bone b in wb.bonelist)
            {
                Gizmos.DrawWireSphere(b.tf.position,collideradius);
            }
        }
    }
}
